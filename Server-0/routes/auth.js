const express = require('express');
const passport = require('passport');
const router = express.Router();

// Google OAuth routes
router.get('/google',
  passport.authenticate('google', { scope: ['profile', 'email'] })
);

router.get('/google/callback',
  passport.authenticate('google', { failureRedirect: '/' }),
  (req, res) => {
    res.redirect('/');
  }
);

router.get('/logout', (req, res) => {
  req.logout(() => {
    res.redirect('/');
  });
});

// User info endpoint
router.get('/user', (req, res) => {
  if (req.isAuthenticated()) {
    res.json({
      isLoggedIn: true,
      email: req.user.emails[0].value,
      name: req.user.displayName
    });
  } else {
    res.json({ isLoggedIn: false });
  }
});

module.exports = router;