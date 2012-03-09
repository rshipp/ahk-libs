using System;
using System.Windows.Forms;
using System.Runtime.InteropServices;

namespace MM_IPC
{
	/// <summary>
	/// Implementation of process communication via WM_COPYDATA
	/// </summary>
	public class IPC : NativeWindow
	{
		/// <summary> Delegate for IPC.OnMessage event. </summary>
		///	<param name="message">Message that was received</param>
		///	<param name="port">Port that received the message</param>
		public delegate void MessageAction(string message, int port);
	
		/// <summary>Event fired when message arrives</summary>
		public event MessageAction OnMessage;

		#region Private fields
		IntPtr		 id = new IntPtr(951753);
		const int	 WM_COPYDATA = 74;
		string		 strData;
			        			
		[StructLayout(LayoutKind.Sequential)]
			struct COPYDATASTRUCT
		{
			public int dwData;
			public int cbData;
			public int lpData;
		}
			
		COPYDATASTRUCT CD;
		#endregion

		#region Win32 imports
		[DllImport("user32.dll", SetLastError = true)]
		private static extern IntPtr FindWindow(string lpClassName, string lpWindowName);
		
		[DllImport("user32.dll",CharSet=CharSet.Ansi)]
		private static extern int SendMessage(IntPtr hWnd, int wMsg, IntPtr wParam, ref COPYDATASTRUCT lParam);	
		#endregion
		
		///<summary> Creates IPC object. </summary>
		///<param name="host">Form object that will monitor and accept communication with other process</param>
		public IPC(Form host) 
		{
			this.AssignHandle(host.Handle);
		}

		
		///<summary> Find window by title </summary>
		///<param name="WinTitle">Window title, case insensitive</param>
		public static IntPtr WinExist( string WinTitle ) 
		{
			return FindWindow(null, WinTitle);
		}
		
		///<summary>Send the message to another process (receiver) using WM_COPYDATA.</summary>
		///<param name="hHost">Handle of the receiver</param>
		///<param name="msg">Message to be sent</param>
		///<param name="port">Port on which to send the message</param>
		public bool Send(IntPtr hHost, string msg, int port)
		{
			COPYDATASTRUCT cd = new COPYDATASTRUCT();
			cd.dwData = port;
			cd.cbData = msg.Length+1;
			cd.lpData = Marshal.StringToHGlobalAnsi(msg).ToInt32();
			
			//IntPtr pcd = Marshal.AllocCoTaskMem(Marshal.SizeOf(cd));	// Alocate memory
			//Marshal.StructureToPtr(cd, pcd, true);					// Converting structure to IntPtr
			int i = SendMessage(hHost, WM_COPYDATA, id, ref cd);	
			return i==1 ? true : false;
		}

		protected override void WndProc(ref Message m)
		{
			if((m.Msg==WM_COPYDATA) && (m.WParam == id))
			{
				CD = (COPYDATASTRUCT)m.GetLParam(typeof(COPYDATASTRUCT));
				strData = Marshal.PtrToStringAnsi(new IntPtr(CD.lpData), CD.cbData);
												
				if (OnMessage != null)
					OnMessage( strData, CD.dwData );

				return;
			}
			
			base.WndProc(ref m);
		}
	}
}