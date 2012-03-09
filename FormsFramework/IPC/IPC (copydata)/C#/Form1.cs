using System;
using System.Drawing;
using System.Collections;
using System.ComponentModel;
using System.Windows.Forms;

using MM_IPC;


namespace WindowsApplication4
{
	public class Form1 : System.Windows.Forms.Form
	{
		private IPC ipc;

		private System.Windows.Forms.ListBox lbPort;
		private System.Windows.Forms.TextBox textBox1;
		private System.Windows.Forms.Button btnSend;
		private System.Windows.Forms.Button btnMassive;
		private System.Windows.Forms.TextBox textBox2;

		private System.ComponentModel.Container components = null;

		public Form1(){
			InitializeComponent();			
			ipc = new IPC(this);
			ipc.OnMessage += new IPC.MessageAction(ipc_OnMessage);
		}
		
		private void ipc_OnMessage( string message, int port ) 
		{
				lbPort.Items.Add( port.ToString() + " - " + message );
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
			this.btnSend = new System.Windows.Forms.Button();
			this.textBox1 = new System.Windows.Forms.TextBox();
			this.btnMassive = new System.Windows.Forms.Button();
			this.textBox2 = new System.Windows.Forms.TextBox();
			this.SuspendLayout();
			// 
			// lbPort
			// 
			this.lbPort.Anchor = ((System.Windows.Forms.AnchorStyles)((((System.Windows.Forms.AnchorStyles.Top | System.Windows.Forms.AnchorStyles.Bottom) 
				| System.Windows.Forms.AnchorStyles.Left) 
				| System.Windows.Forms.AnchorStyles.Right)));
			this.lbPort.Location = new System.Drawing.Point(0, 40);
			this.lbPort.Name = "lbPort";
			this.lbPort.Size = new System.Drawing.Size(356, 277);
			this.lbPort.TabIndex = 0;
			// 
			// btnSend
			// 
			this.btnSend.Location = new System.Drawing.Point(240, 8);
			this.btnSend.Name = "btnSend";
			this.btnSend.Size = new System.Drawing.Size(48, 24);
			this.btnSend.TabIndex = 1;
			this.btnSend.Text = "Send";
			this.btnSend.Click += new System.EventHandler(this.btnSend_Click);
			// 
			// textBox1
			// 
			this.textBox1.Location = new System.Drawing.Point(0, 8);
			this.textBox1.Name = "textBox1";
			this.textBox1.Size = new System.Drawing.Size(208, 20);
			this.textBox1.TabIndex = 2;
			this.textBox1.Text = "C# message to AHK";
			// 
			// btnMassive
			// 
			this.btnMassive.Location = new System.Drawing.Point(288, 8);
			this.btnMassive.Name = "btnMassive";
			this.btnMassive.Size = new System.Drawing.Size(56, 24);
			this.btnMassive.TabIndex = 3;
			this.btnMassive.Text = "Massive";
			this.btnMassive.Click += new System.EventHandler(this.btnMassive_Click);
			// 
			// textBox2
			// 
			this.textBox2.Location = new System.Drawing.Point(208, 8);
			this.textBox2.Name = "textBox2";
			this.textBox2.Size = new System.Drawing.Size(32, 20);
			this.textBox2.TabIndex = 4;
			this.textBox2.Text = "100";
			// 
			// Form1
			// 
			this.AutoScaleBaseSize = new System.Drawing.Size(5, 13);
			this.ClientSize = new System.Drawing.Size(352, 326);
			this.Controls.Add(this.textBox2);
			this.Controls.Add(this.btnMassive);
			this.Controls.Add(this.textBox1);
			this.Controls.Add(this.btnSend);
			this.Controls.Add(this.lbPort);
			this.Name = "Form1";
			this.Text = "Form1";
			this.TopMost = true;
			this.ResumeLayout(false);

		}
		#endregion

		[STAThread]
		static void Main() 
		{
			Application.Run( new Form1() );
		}

		private void btnSend_Click(object sender, System.EventArgs e)
		{
			IntPtr hHost = IPC.WinExist("Client");
			if (!ipc.Send( hHost, textBox1.Text, Convert.ToInt32(textBox2.Text)))
				MessageBox.Show("Sending failed");
		}

		private void btnMassive_Click(object sender, System.EventArgs e)
		{
			IntPtr hHost = IPC.WinExist("Client");
			if (hHost == IntPtr.Zero) 
			{
				MessageBox.Show("Client doesn't exist");
				return;
			}

			for (int i=1; i<=100; i++)
				ipc.Send( hHost, textBox1.Text + " : " + i.ToString(), Convert.ToInt32(textBox2.Text));
		}
	}
}
