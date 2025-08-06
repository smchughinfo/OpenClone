// Licensed to the .NET Foundation under one or more agreements.
// The .NET Foundation licenses this file to you under the MIT license.
#nullable disable

using System;
using System.ComponentModel.DataAnnotations;
using System.Text.Encodings.Web;
using System.Threading.Tasks;
using Microsoft.AspNetCore.Identity;
using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Mvc.RazorPages;
using OpenClone.Core.Models;
using System.Collections.Generic;
using System.Linq;

namespace OpenClone.Areas.Identity.Pages.Account.Manage
{
    public class IndexModel : PageModel
    {
        private readonly UserManager<ApplicationUser> _userManager;
        private readonly SignInManager<ApplicationUser> _signInManager;

        public IndexModel(
            UserManager<ApplicationUser> userManager,
            SignInManager<ApplicationUser> signInManager)
        {
            _userManager = userManager;
            _signInManager = signInManager;
        }

        public List<ApplicationUser> Users { get; set; } = new List<ApplicationUser>();
        public bool IsAdmin { get; set; }
        
        [TempData]
        public string StatusMessage { get; set; }

        private async Task LoadAsync(ApplicationUser user)
        {
            IsAdmin = await _userManager.IsInRoleAsync(user, "Admin");
            
            if (IsAdmin)
            {
                Users = _userManager.Users.ToList();
            }
            else
            {
                Users = new List<ApplicationUser> { user };
            }
        }

        public async Task<IActionResult> OnGetAsync()
        {
            var user = await _userManager.GetUserAsync(User);
            if (user == null)
            {
                return NotFound($"Unable to load user with ID '{_userManager.GetUserId(User)}'.");
            }

            await LoadAsync(user);
            return Page();
        }

        public async Task<IActionResult> OnPostDeleteAsync(string userId)
        {
            var currentUser = await _userManager.GetUserAsync(User);
            if (currentUser == null)
            {
                return NotFound($"Unable to load current user.");
            }

            var userToDelete = await _userManager.FindByIdAsync(userId);
            if (userToDelete == null)
            {
                StatusMessage = "Error: User not found.";
                return RedirectToPage();
            }

            var isAdmin = await _userManager.IsInRoleAsync(currentUser, "Admin");
            
            if (!isAdmin && currentUser.Id != userId)
            {
                StatusMessage = "Error: You can only delete your own account.";
                return RedirectToPage();
            }

            var result = await _userManager.DeleteAsync(userToDelete);
            if (result.Succeeded)
            {
                if (currentUser.Id == userId)
                {
                    await _signInManager.SignOutAsync();
                    return Redirect("/");
                }
                else
                {
                    StatusMessage = $"User {userToDelete.UserName} has been deleted.";
                }
            }
            else
            {
                StatusMessage = "Error: Could not delete user.";
            }

            return RedirectToPage();
        }
    }
}