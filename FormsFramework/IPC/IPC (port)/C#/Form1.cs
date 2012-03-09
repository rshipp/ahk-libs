using System;
using System.Drawing;
using System.Collections;
using System.ComponentModel;
using System.Windows.Forms;
using System.Data;
using System.Runtime.InteropServices;



namespace WindowsApplication4
{
	public class Form1 : System.Windows.Forms.Form
	{
		private IPC ipc;

		private System.Windows.Forms.ListBox lbPort;

		private System.ComponentModel.Container components = null;

		public Form1(){
			InitializeComponent();			
			ipc = new IPC();
			ipc.OnMessage += new IPC.MessageAction(ipc_OnMessage);
		}
		
		private void ipc_OnMessage( string message ) 
		{
				lbPort.Items.Add( message );
		}

		protected override void Dispose( bool disposing )
		{
			if( disposing )
			{
				if (components != null) 
				{
					components.Dispose();
				}
			}
			base.Dispose( disposing );
		}

		#region Windows Form Designer generated code
		/// <summary>
		/// Required method for Designer support - do not modify
		/// the contents of this method with the code editor.
		/// </summary>
		private void InitializeComponent()
		{
			this.lbPort = new System.Windows.Forms.ListBox();
			this.SuspendLayout();
			// 
			// lbPort
			// 
			this.lbPort.Location = new System.Drawing.Point(0, 0);
			this.lbPort.Name = "lbPort";
			this.lbPort.Size = new System.Drawing.Size(296, 264);
			this.lbPort.TabIndex = 0;
			// 
			// Form1
			// 
			this.AutoScaleBaseSize = new System.Drawing.Size(5, 13);
			this.ClientSize = new System.Drawing.Size(292, 266);
			this.Controls.Add(this.lbPort);
			this.Name = "Form1";
			this.Text = "Form1";
			this.Load += new System.EventHandler(this.Form1_Load);
			this.ResumeLayout(false);

		}
		#endregion

		[STAThread]
		static void Main() 
		{
			Application.Run( new Form1() );
		}

		private void Form1_Load(object sender, System.EventArgs e)
		{
		
		}


		private void label1_Click(object sender, System.EventArgs e)
		{
		
		}

	}


	public class IPC : IMessageFilter
	{
		public delegate void MessageAction(string message);
		public event MessageAction OnMessage;

		#region Private fields
			private		TextBox		tbPort;
			private		const int	WM_IPC_GETPORT = 0x8001;
		#endregion
		

		public IPC() 
		{
			Application.AddMessageFilter(this);
		}
		
		
		[DllImport("user32.dll",CharSet=CharSet.Auto)]
		private static extern int SendMessage(int hWnd, int wMsg, int wParam, int lParam);		
		private void tbPort_TextChanged(object sender, System.EventArgs e)
		{
			if (OnMessage != null)
				OnMessage( tbPort.Text );
		}

		public  bool PreFilterMessage(ref Message m)
		{
			if(m.Msg == WM_IPC_GETPORT)
			{						
				if (tbPort == null ) 
				{
					tbPort = new TextBox();
					tbPort.Visible = false;
			
					tbPort.TextChanged += new System.EventHandler( this.tbPort_TextChanged );
				}

				SendMessage( m.WParam.ToInt32(), WM_IPC_GETPORT, tbPort.Handle.ToInt32(), 0);
				return true;
			}			
			return false;
		}
	}

}
