using Microsoft.AspNetCore.Identity.UI.Services;
using System.Net.Mail;
using System.Net;
using OpenClone;
using OpenClone.Services;
using OpenClone.Services.Services;

namespace OpenClone.Services.Services
{
    public class EmailSenderService : IEmailSender
    {
        public async Task SendEmailAsync(string toEmail, string subject, string message)
        {
            await Execute("Options.SendGridKey", subject, message, toEmail);
        }

        public async Task Execute(string apiKey, string subject, string message, string toEmail)
        {
            await Task.Run(() =>
            {
                try
                {
                    SendEmail("admin@openclone.ai", Environment.GetEnvironmentVariable("OpenClone_ZOHO_EMAIL_PASSWORD"), toEmail, message);
                }
                catch (Exception ex)
                {
                    //Console.WriteLine("Error sending email: " + ex.Message);
                }
            });
            return;
        }

        static void SendEmail(string fromEmail, string fromPassword, string toEmail, string message)
        {
            // Set up the email message
            MailMessage mailMessage = new MailMessage(fromEmail, toEmail);
            mailMessage.Subject = "Please confirm your email";
            mailMessage.Body = message;
            mailMessage.IsBodyHtml = true;

            // Configure the SMTP client
            SmtpClient smtpClient = new SmtpClient("smtppro.zoho.com", 587);
            smtpClient.EnableSsl = true;
            smtpClient.DeliveryMethod = SmtpDeliveryMethod.Network;
            smtpClient.UseDefaultCredentials = false;
            smtpClient.Credentials = new NetworkCredential(fromEmail, fromPassword);

            // Send the email
            smtpClient.Send(mailMessage);
        }
    }
}
