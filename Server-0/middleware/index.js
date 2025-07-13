const cors = require('cors');
const helmet = require('helmet');
const morgan = require('morgan');
const express = require('express');

const setupMiddleware = (app) => {
  // Security middleware
  app.use(helmet({
    contentSecurityPolicy: {
      directives: {
        defaultSrc: ["'self'"],
        styleSrc: ["'self'", "'unsafe-inline'"],
        scriptSrc: ["'self'", "'unsafe-inline'", "https://js.stripe.com"],
        frameSrc: ["'self'", "https://js.stripe.com"],
        imgSrc: ["'self'", "data:", "https:"],
      },
    },
  }));
  
  // Other middleware
  app.use(cors());
  app.use(morgan('combined'));
  
  // JSON parsing - exclude webhook routes that need raw body
  app.use((req, res, next) => {
    if (req.path.startsWith('/webhooks/stripe')) {
      next(); // Skip JSON parsing for webhook routes
    } else {
      express.json()(req, res, next); // Apply JSON parsing for other routes
    }
  });
  
  app.use(express.urlencoded({ extended: true }));
  app.use(express.static('public'));
};

module.exports = setupMiddleware;