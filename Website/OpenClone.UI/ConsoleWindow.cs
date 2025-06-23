using System;
using System.Runtime.InteropServices;

namespace OpenClone.UI
{
#if  BUILDING_ON_WINDOWS
    public class ConsoleWindow
    {
        [DllImport("kernel32.dll", SetLastError = true)]
        private static extern IntPtr GetConsoleWindow();

        [DllImport("user32.dll", SetLastError = true)]
        private static extern bool SetWindowPos(IntPtr hWnd, IntPtr hWndInsertAfter, int X, int Y, int cx, int cy, uint uFlags);

        [DllImport("user32.dll", SetLastError = true)]
        private static extern bool ShowWindow(IntPtr hWnd, int nCmdShow);

        private const int SW_RESTORE = 9;
        private const int SW_MINIMIZE = 6;
        private const uint SWP_NOZORDER = 0x0004;

        public static void Restore()
        {
            var handle = GetConsoleWindow();
            ShowWindow(handle, SW_RESTORE);
        }

        public static void Minimize()
        {
            var handle = GetConsoleWindow();
            ShowWindow(handle, SW_MINIMIZE); // Use the SW_MINIMIZE command to minimize the window
        }

        public static void SetPositionAndSize(int x, int y, int width, int height)
        {
            // First, restore the window if it's minimized
            Restore();

            // For more precise control, use the SetWindowPos Windows API function
            var handle = GetConsoleWindow();
            SetWindowPos(handle, IntPtr.Zero, x, y, width, height, SWP_NOZORDER);
        }
    }
#endif
}
