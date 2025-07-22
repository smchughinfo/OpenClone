const issueRefund = async (paymentIntentId, paymentData) => {
  try {
    const stripe = require('stripe')(process.env.STRIPE_SECRET_KEY);

    console.log('💳 Issuing immediate refund for payment intent:', paymentIntentId);
    const refund = await stripe.refunds.create({
      payment_intent: paymentIntentId,
      reason: 'requested_by_customer'
    });

    console.log('💸 REFUND ISSUED:', {
      paymentIntentId,
      refundId: refund.id,
      amount: paymentData.amount,
      email: paymentData.email
    });

  } catch (error) {
    console.error('❌ Refund failed:', error.message);
  }
};

module.exports = { issueRefund };