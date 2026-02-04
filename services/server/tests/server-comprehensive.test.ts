import { describe, it, expect, beforeAll, afterAll, vi } from 'vitest';
import request from 'supertest';
import WebSocket, { WebSocketServer } from 'ws';
import express from 'express';
import { createServer } from 'http';
import cors from 'cors';

// Mock the routes and vite modules
vi.mock('../routes.js', () => ({
  registerRoutes: vi.fn((app) => {
    app.get('/api/test', (req, res) => res.json({ message: 'test endpoint' }));
    app.post('/api/data', (req, res) => res.json({ received: req.body }));
    app.get('/api/error', (req, res) => { throw new Error('Test error'); });
  })
}));

vi.mock('../vite.js', () => ({
  setupVite: vi.fn(),
  serveStatic: vi.fn()
}));

describe('GenX FX Server Comprehensive Tests', () => {
  let app: express.Application;
  let server: any;
  let wss: WebSocketServer;
  let baseURL: string;

  beforeAll(async () => {
    // Create test server similar to main server
    app = express();
    
    // CORS configuration
    app.use(cors({
      origin: ['http://localhost:3000', 'http://0.0.0.0:3000'],
      credentials: true
    }));

    app.use(express.json({ limit: '10mb' }));
    app.use(express.urlencoded({ extended: true }));

    // Health check endpoint
    app.get('/health', (req, res) => {
      res.json({ 
        status: 'OK', 
        timestamp: new Date().toISOString(),
        environment: process.env.NODE_ENV || 'development'
      });
    });

    // Mock routes
    const { registerRoutes } = await import('../routes.js');
    registerRoutes(app);

    // Specific error handler for json parsing errors
    app.use((err: any, req: any, res: any, next: any) => {
      if (err.type === 'entity.too.large') {
        return res.status(413).json({ error: 'Payload Too Large' });
      }
      if (err instanceof SyntaxError && 'status' in err && err.status === 400) {
        return res.status(400).json({ error: 'Bad Request' });
      }
      next(err);
    });

    // Generic error handling middleware
    app.use((err: any, req: any, res: any, next: any) => {
      const statusCode = err.statusCode || 500;
      res.status(statusCode).json({
        error: err.name || 'Internal server error',
        message: process.env.NODE_ENV === 'development' ? err.message : 'Something went wrong'
      });
    });

    // 404 handler
    app.use((req, res) => {
      res.status(404).json({
        error: 'Not found',
        path: req.originalUrl
      });
    });

    server = createServer(app);
    const port = 5001; // Use different port for tests
    server.listen(port);
    baseURL = `http://localhost:${port}`;

    wss = new WebSocketServer({ server });
    wss.on('connection', (ws) => {
      ws.send(JSON.stringify({
        type: 'welcome',
        message: 'Connected to GenZ Trading Bot Pro',
        timestamp: new Date().toISOString()
      }));

      ws.on('message', (message) => {
        try {
          const parsedMessage = JSON.parse(message.toString());
          ws.send(JSON.stringify({
            type: 'echo',
            data: parsedMessage,
            timestamp: new Date().toISOString()
          }));
        } catch (e) {
          ws.send(JSON.stringify({
            type: 'error',
            message: 'Invalid JSON format'
          }));
        }
      });
    });
  });

  afterAll(async () => {
    if (wss) {
      wss.close();
    }
    if (server) {
      server.close();
    }
  });

  describe('HTTP Server Tests', () => {
    it('should return health check with correct format', async () => {
      const response = await request(app).get('/health');
      
      expect(response.status).toBe(200);
      expect(response.body).toHaveProperty('status', 'OK');
      expect(response.body).toHaveProperty('timestamp');
      expect(response.body).toHaveProperty('environment');
      expect(new Date(response.body.timestamp)).toBeInstanceOf(Date);
    });

    it('should handle CORS correctly', async () => {
      const response = await request(app)
        .get('/health')
        .set('Origin', 'http://localhost:3000');
      
      expect(response.headers['access-control-allow-origin']).toBe('http://localhost:3000');
      expect(response.headers['access-control-allow-credentials']).toBe('true');
    });

    it('should parse JSON correctly', async () => {
      const testData = { test: 'data', number: 123, nested: { value: true } };
      
      const response = await request(app)
        .post('/api/data')
        .send(testData);
      
      expect(response.status).toBe(200);
      expect(response.body.received).toEqual(testData);
    });

    it('should handle large JSON payloads (under 10MB limit)', async () => {
      const largeData = {
        data: 'x'.repeat(1024 * 1024), // 1MB string
        array: new Array(1000).fill({ test: 'data' })
      };
      
      const response = await request(app)
        .post('/api/data')
        .send(largeData);
      
      expect(response.status).toBe(200);
      expect(response.body.received.data).toBe(largeData.data);
    });

    it('should reject payloads exceeding 10MB limit', async () => {
      const oversizedData = {
        data: 'x'.repeat(11 * 1024 * 1024) // 11MB string
      };
      
      const response = await request(app)
        .post('/api/data')
        .send(oversizedData);
      
      expect(response.status).toBe(413); // Payload Too Large
    });

    it('should handle malformed JSON gracefully', async () => {
      const response = await request(app)
        .post('/api/data')
        .set('Content-Type', 'application/json')
        .send('{ invalid json }');
      
      expect(response.status).toBe(400); // Bad Request
    });

    it('should handle server errors with proper error response', async () => {
      const response = await request(app).get('/api/error');
      
      expect(response.status).toBe(500);
      expect(response.body).toHaveProperty('error', 'Error');
      expect(response.body).toHaveProperty('message');
    });

    it('should return 404 for unknown routes', async () => {
      const response = await request(app).get('/non-existent-route');
      
      expect(response.status).toBe(404);
      expect(response.body).toHaveProperty('error', 'Not found');
      expect(response.body).toHaveProperty('path', '/non-existent-route');
    });
  });

  describe('Edge Cases', () => {
    it('should handle empty request body', async () => {
      const response = await request(app)
        .post('/api/data')
        .send({});
      
      expect(response.status).toBe(200);
      expect(response.body.received).toEqual({});
    });

    it('should handle null values in JSON', async () => {
      const testData = { 
        nullValue: null, 
        emptyString: '', 
        zero: 0, 
        falseValue: false 
      };
      
      const response = await request(app)
        .post('/api/data')
        .send(testData);
      
      expect(response.status).toBe(200);
      expect(response.body.received).toEqual(testData);
    });

    it('should handle special characters and unicode', async () => {
      const testData = { 
        emoji: '🚀📊💹',
        special: '!@#$%^&*()_+-=[]{}|;:,.<>?',
        unicode: 'café résumé naïve',
        chinese: '测试数据'
      };
      
      const response = await request(app)
        .post('/api/data')
        .send(testData);
      
      expect(response.status).toBe(200);
      expect(response.body.received).toEqual(testData);
    });

    it('should handle arrays with mixed types', async () => {
      const testData = { 
        mixedArray: [1, 'string', null, true, { nested: 'object' }, [1, 2, 3]]
      };
      
      const response = await request(app)
        .post('/api/data')
        .send(testData);
      
      expect(response.status).toBe(200);
      expect(response.body.received).toEqual(testData);
    });

    it('should handle deeply nested objects', async () => {
      const testData = {
        level1: {
          level2: {
            level3: {
              level4: {
                level5: {
                  deepValue: 'found'
                }
              }
            }
          }
        }
      };
      
      const response = await request(app)
        .post('/api/data')
        .send(testData);
      
      expect(response.status).toBe(200);
      expect(response.body.received.level1.level2.level3.level4.level5.deepValue).toBe('found');
    });
  });

  describe('WebSocket Tests', () => {
    it('should establish WebSocket connection and send welcome message', async () => {
      await new Promise<void>((resolve, reject) => {
        const ws = new WebSocket(`ws://localhost:5001`);
        ws.on('message', (data) => {
          const message = JSON.parse(data.toString());
          if (message.type === 'welcome') {
            expect(message.message).toBe('Connected to GenZ Trading Bot Pro');
            expect(message.timestamp).toBeDefined();
            ws.close();
            resolve();
          }
        });
        ws.on('error', reject);
      });
    }, 1000);

    it('should echo back valid JSON messages', async () => {
      await new Promise<void>((resolve, reject) => {
        const ws = new WebSocket(`ws://localhost:5001`);
        const testMessage = { action: 'test', data: { value: 123 } };
        let welcomeReceived = false;
        
        ws.on('message', (data) => {
          const message = JSON.parse(data.toString());

          if (message.type === 'welcome') {
            welcomeReceived = true;
            ws.send(JSON.stringify(testMessage));
          } else if (message.type === 'echo' && welcomeReceived) {
            expect(message.data).toEqual(testMessage);
            expect(message.timestamp).toBeDefined();
            ws.close();
            resolve();
          }
        });
        ws.on('error', reject);
      });
    }, 1000);

    it('should handle invalid JSON messages gracefully', async () => {
      await new Promise<void>((resolve, reject) => {
        const ws = new WebSocket(`ws://localhost:5001`);
        let welcomeReceived = false;
        
        ws.on('message', (data) => {
          const message = JSON.parse(data.toString());

          if (message.type === 'welcome') {
            welcomeReceived = true;
            ws.send('{ invalid json }');
          } else if (message.type === 'error' && welcomeReceived) {
            expect(message.message).toBe('Invalid JSON format');
            ws.close();
            resolve();
          }
        });
        ws.on('error', reject);
      });
    }, 1000);
  });
});
