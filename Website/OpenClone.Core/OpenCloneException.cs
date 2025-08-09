using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace OpenClone.Core
{

    // important note - this class is implemented in ExceptionHandlingMiddleware.cs
    public class OpenCloneException : Exception
    {
        // i thought it would be a good idea to put all of the error messages together so you can see if they sound consisent.
        public const string CLONE_DUP_CHECK_FAILED = "Clone with first name [FirstName] already exists (duplicate check ignores case).";
        public const string CLONE_CREATION_FAILED = "An unhandled error occured while creating the clone.";
        public const string CLONE_UPDATE_FAILED = "An unhandled error occured while updating the clone.";
        public const string DELETE_CLONE_FAILED = "An unhandled error occured while deleting the clone. The clone has not been deleted.";
        public const string GENERATE_QUESTION_STARTER_IDEAS_FAILED = "Unable to generate question starter ideas. The question may be phrased too simply. Try adding more detail.";
        public const string DEEPFAKE_FAILED = "DeepFake generation failed to complete on time";

        public bool SendDetailsToUser { get; set; }
        public bool? ForceLog { get; set; }

        /// <summary>
        /// 
        /// </summary>
        /// <param name="message">The error message</param>
        /// <param name="allowTopExceptionToBeShownToUser">Whether or not the error message should be shown to the user.</param>
        /// <param name="innerException">note - the inner exception may be logged but not shown to the user.</param>
        /// <param name="forceLog">If a value is provided this acts as an override. T/F means logging will/will-not be done.</param>
        public OpenCloneException(string message, bool allowTopExceptionToBeShownToUser, Exception? innerException = null, bool? forceLog = null)
            : base(message, innerException)
        {
            SendDetailsToUser = allowTopExceptionToBeShownToUser;
            ForceLog = forceLog;
        }
    }
}
