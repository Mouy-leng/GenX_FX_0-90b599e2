import React, { useState } from 'react';
import { useForm, SubmitHandler } from 'react-hook-form';
import { Loader2, Lock } from 'lucide-react';

interface IFormInput {
  cardholderName: string;
  cardNumber: string;
  expiryDate: string;
  cvc: string;
}

const Billing: React.FC = () => {
  const [status, setStatus] = useState<{ type: 'success' | 'error'; message: string } | null>(null);
  const { register, handleSubmit, formState: { errors, isSubmitting } } = useForm<IFormInput>();
  const onSubmit: SubmitHandler<IFormInput> = async (data) => {
    try {
      const response = await fetch('/api/v1/billing', {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
        },
        body: JSON.stringify(data),
      });
      if (response.ok) {
        setStatus({ type: 'success', message: 'Payment method added successfully' });
      } else {
        setStatus({ type: 'error', message: 'Failed to add payment method' });
      }
    } catch (error) {
      console.error('Error adding payment method:', error);
      setStatus({ type: 'error', message: 'An error occurred while adding the payment method' });
    }
  };

  return (
    <div className="p-4 max-w-2xl mx-auto">
      <h1 className="text-2xl font-bold mb-4">Billing</h1>
      <div className="bg-white rounded-lg shadow-md p-6">
        <h2 className="text-xl font-semibold mb-4">Add a Payment Method</h2>
        <form onSubmit={handleSubmit(onSubmit)}>
          <div className="mb-4">
            <label htmlFor="cardholderName" className="block text-gray-700 font-medium mb-2">Cardholder Name</label>
            <input
              id="cardholderName"
              className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-blue-500"
              {...register("cardholderName", { required: "Cardholder name is required" })}
            />
            {errors.cardholderName && <p className="text-red-500 text-sm mt-1">{errors.cardholderName.message}</p>}
          </div>
          <div className="mb-4">
            <label htmlFor="cardNumber" className="block text-gray-700 font-medium mb-2">Card Number</label>
            <input
              id="cardNumber"
              className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-blue-500"
              {...register("cardNumber", { required: "Card number is required" })}
            />
            {errors.cardNumber && <p className="text-red-500 text-sm mt-1">{errors.cardNumber.message}</p>}
          </div>
          <div className="grid grid-cols-2 gap-4 mb-4">
            <div>
              <label htmlFor="expiryDate" className="block text-gray-700 font-medium mb-2">Expiry Date (MM/YY)</label>
              <input
                id="expiryDate"
                className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-blue-500"
                {...register("expiryDate", { required: "Expiry date is required" })}
              />
              {errors.expiryDate && <p className="text-red-500 text-sm mt-1">{errors.expiryDate.message}</p>}
            </div>
            <div>
              <label htmlFor="cvc" className="block text-gray-700 font-medium mb-2">CVC</label>
              <input
                id="cvc"
                className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-blue-500"
                {...register("cvc", { required: "CVC is required" })}
              />
              {errors.cvc && <p className="text-red-500 text-sm mt-1">{errors.cvc.message}</p>}
            </div>
          </div>
          <button
            type="submit"
            disabled={isSubmitting}
            className="flex items-center justify-center gap-2 bg-blue-600 text-white px-4 py-2 rounded-lg hover:bg-blue-700 w-full disabled:opacity-70 disabled:cursor-not-allowed transition-colors focus:outline-none focus:ring-2 focus:ring-blue-500 focus:ring-offset-2"
            aria-live="polite"
          >
            {isSubmitting ? (
              <>
                <Loader2 className="w-5 h-5 animate-spin" aria-hidden="true" />
                <span>Processing...</span>
              </>
            ) : (
              <>
                <Lock className="w-4 h-4" aria-hidden="true" />
                <span>Add Payment Method</span>
              </>
            )}
          </button>
        </form>
        {status && (
          <div className={`mt-4 p-4 rounded-lg ${status.type === 'success' ? 'bg-green-100 text-green-800' : 'bg-red-100 text-red-800'}`}>
            {status.message}
          </div>
        )}
      </div>
    </div>
  );
};

export default Billing;
