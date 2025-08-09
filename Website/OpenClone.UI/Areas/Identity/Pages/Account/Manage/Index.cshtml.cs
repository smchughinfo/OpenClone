// Licensed to the .NET Foundation under one or more agreements.
// The .NET Foundation licenses this file to you under the MIT license.
#nullable disable

using Microsoft.AspNetCore.Identity;
using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Mvc.RazorPages;
using OpenClone.Core.Models;
using OpenClone.Services.Services;
using OpenClone.Services.Services.ElevenLabs;
using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.Linq;
using System.Text.Encodings.Web;
using System.Threading.Tasks;

namespace OpenClone.Areas.Identity.Pages.Account.Manage
{
    public class IndexModel : PageModel
    {
        private readonly UserManager<ApplicationUser> _userManager;
        private readonly SignInManager<ApplicationUser> _signInManager;
        private readonly CloneCRUDService _cloneCRUDService;
        private readonly ElevenLabsService _elevenLabsService;
        private readonly CloneMetadataService _cloneMetadataService;
        public IndexModel(
            UserManager<ApplicationUser> userManager,
            SignInManager<ApplicationUser> signInManager,
            CloneCRUDService cloneCRUDService,
            ElevenLabsService elevenLabsService, 
            CloneMetadataService cloneMetadataService
            )
        {
            _userManager = userManager;
            _signInManager = signInManager;
            _cloneCRUDService = cloneCRUDService;
            _elevenLabsService = elevenLabsService;
            _cloneMetadataService = cloneMetadataService;
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
            // verify that account can be deleted
            var deletionError = await HandleCantDeleteScenarios(userId);
            if(deletionError != null) {
                return deletionError;
            }

            // delete the account
            var userDeletingOwnAccount = (await _userManager.GetUserAsync(User)).Id == userId;
            var deleteSucceeded = await DeleteAccountAsync(userId);

            // route user after account deletion
            return await RouteUserAfterAccountDeletion(userDeletingOwnAccount, userId, deleteSucceeded);
        }

        public async Task<IActionResult> HandleCantDeleteScenarios(string userId)
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

            return null;
        }

        private async Task<bool> DeleteAccountAsync(string userId)
        {
            var usersClones = _cloneCRUDService.GetClones(userId);
            foreach (var userClone in usersClones)
            {
                await _elevenLabsService.DeleteVoice(userClone.VoiceId, userClone.AllowLogging);
                await _cloneCRUDService.DeleteClone(userId, userClone.Id);
            }

            var userToDelete = await _userManager.FindByIdAsync(userId);
            var result = await _userManager.DeleteAsync(userToDelete);
            return result.Succeeded;
        }

        private async Task<IActionResult> RouteUserAfterAccountDeletion(bool userDeletedOwnAccount, string userId, bool deleteSucceeded)
        {
            var userToDelete = await _userManager.FindByIdAsync(userId);
            if (deleteSucceeded)
            {
                if (userDeletedOwnAccount)
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