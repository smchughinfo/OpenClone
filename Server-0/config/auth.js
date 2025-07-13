const session = require('express-session');
const passport = require('passport');
const GoogleStrategy = require('passport-google-oauth20').Strategy;

// Session configuration
const sessionConfig = {
  secret: process.env.SESSION_SECRET || 'your-super-secret-key-change-this',
  resave: false,
  saveUninitialized: false,
  cookie: { secure: false } // Set to true if using HTTPS
};

// Initialize Google Strategy function - called after app setup
const initializeGoogleStrategy = () => {
  console.log('Auth config - checking environment variables:');
  console.log('GOOGLE_CLIENT_ID present:', !!process.env.GOOGLE_CLIENT_ID);
  console.log('GOOGLE_CLIENT_SECRET present:', !!process.env.GOOGLE_CLIENT_SECRET);

  if (process.env.GOOGLE_CLIENT_ID && process.env.GOOGLE_CLIENT_SECRET) {
    console.log('Initializing Google OAuth Strategy...');
    passport.use(new GoogleStrategy({
      clientID: process.env.GOOGLE_CLIENT_ID,
      clientSecret: process.env.GOOGLE_CLIENT_SECRET,
      callbackURL: "https://clonezone.me/auth/signin-google",
      scope: ['profile', 'email']
    }, (accessToken, refreshToken, profile, done) => {
      // In a real app, save user to database
      return done(null, profile);
    }));
    return true;
  } else {
    console.error('Google OAuth environment variables missing - OAuth routes will not work');
    return false;
  }
};

passport.serializeUser((user, done) => {
  done(null, user);
});

passport.deserializeUser((user, done) => {
  done(null, user);
});

// Export configuration function
module.exports = (app) => {
  app.use(session(sessionConfig));
  app.use(passport.initialize());
  app.use(passport.session());
  
  // Initialize Google Strategy after session setup
  const oauthConfigured = initializeGoogleStrategy();
  
  // Store OAuth status for routes to check
  app.locals.isOAuthConfigured = oauthConfigured;
};