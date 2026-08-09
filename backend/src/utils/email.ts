import nodemailer from "nodemailer";

// ─── SMTP Transporter ─────────────────────────────────────────────────────────

function getTransporter() {
  const host = process.env.SMTP_HOST;
  const port = Number(process.env.SMTP_PORT) || 587;
  const user = process.env.SMTP_USER;
  const pass = process.env.SMTP_PASS;

  if (
    !host ||
    !user ||
    !pass ||
    user.includes("your_email") ||
    pass.includes("your_app_password")
  ) {
    return null;
  }

  return nodemailer.createTransport({
    host,
    port,
    secure: port === 465, // true for 465, false for other ports (587, 25)
    auth: {
      user,
      pass,
    },
  });
}

const FROM_EMAIL = process.env.SMTP_FROM || `"ROUJLI" <${process.env.SMTP_USER || "noreply@roujli.com"}>`;

// ─── Send Verification Email ──────────────────────────────────────────────────

export async function sendVerificationEmail(
  email: string,
  firstName: string,
  code: string
): Promise<void> {
  const transporter = getTransporter();

  if (!transporter) {
    console.log(`\n==================================================`);
    console.log(`[DEV FALLBACK] SMTP settings missing in .env!`);
    console.log(`[DEV FALLBACK] Verification OTP for ${email} (${firstName}): ${code}`);
    console.log(`==================================================\n`);
    return;
  }

  try {
    await transporter.sendMail({
      from: FROM_EMAIL,
      to: email,
      subject: "Verify your ROUJLI account",
      html: `
        <!DOCTYPE html>
        <html>
          <head>
            <meta charset="utf-8" />
            <meta name="viewport" content="width=device-width, initial-scale=1" />
          </head>
          <body style="margin:0;padding:0;background:#0A0A0A;font-family:Arial,sans-serif;">
            <table width="100%" cellpadding="0" cellspacing="0" style="background:#0A0A0A;padding:40px 20px;">
              <tr>
                <td align="center">
                  <table width="480" cellpadding="0" cellspacing="0" style="background:#141414;border-radius:16px;padding:40px;border:1px solid #2A2A2A;">
                    <tr>
                      <td align="center" style="padding-bottom:32px;">
                        <h1 style="color:#E8B923;font-size:28px;margin:0;letter-spacing:4px;">ROUJLI</h1>
                        <p style="color:#6B6B6B;font-size:12px;margin:6px 0 0;letter-spacing:1px;">BUSINESS GROWTH OPERATING SYSTEM</p>
                      </td>
                    </tr>
                    <tr>
                      <td>
                        <h2 style="color:#FFFFFF;font-size:22px;margin:0 0 12px;">Hi ${firstName},</h2>
                        <p style="color:#9E9E9E;font-size:15px;line-height:1.6;margin:0 0 32px;">
                          Welcome to ROUJLI! Please verify your email address by entering this code in the app:
                        </p>
                        <div style="background:#1A1A1A;border-radius:12px;padding:24px;text-align:center;margin-bottom:32px;border:1px solid #2A2A2A;">
                          <span style="color:#E8B923;font-size:40px;font-weight:bold;letter-spacing:12px;">${code}</span>
                        </div>
                        <p style="color:#6B6B6B;font-size:13px;line-height:1.5;margin:0;">
                          This code expires in <strong style="color:#9E9E9E;">10 minutes</strong>. 
                          If you didn't create a ROUJLI account, you can safely ignore this email.
                        </p>
                      </td>
                    </tr>
                    <tr>
                      <td style="padding-top:32px;border-top:1px solid #2A2A2A;margin-top:32px;">
                        <p style="color:#6B6B6B;font-size:12px;text-align:center;margin:0;">
                          © 2026 ROUJLI. All rights reserved.
                        </p>
                      </td>
                    </tr>
                  </table>
                </td>
              </tr>
            </table>
          </body>
        </html>
      `,
    });
  } catch (err: any) {
    console.warn(`[SMTP Error] Could not deliver email to ${email}: ${err?.message || err}`);
    console.log(`\n==================================================`);
    console.log(`[DEV FALLBACK] Verification OTP for ${email} (${firstName}): ${code}`);
    console.log(`==================================================\n`);
  }
}

// ─── Send Password Reset Email ────────────────────────────────────────────────

export async function sendPasswordResetEmail(
  email: string,
  firstName: string,
  code: string
): Promise<void> {
  const transporter = getTransporter();

  if (!transporter) {
    console.log(`\n==================================================`);
    console.log(`[DEV FALLBACK] SMTP settings missing in .env!`);
    console.log(`[DEV FALLBACK] Password Reset OTP for ${email} (${firstName}): ${code}`);
    console.log(`==================================================\n`);
    return;
  }

  try {
    await transporter.sendMail({
      from: FROM_EMAIL,
      to: email,
      subject: "Reset your ROUJLI password",
      html: `
        <!DOCTYPE html>
        <html>
          <head>
            <meta charset="utf-8" />
            <meta name="viewport" content="width=device-width, initial-scale=1" />
          </head>
          <body style="margin:0;padding:0;background:#0A0A0A;font-family:Arial,sans-serif;">
            <table width="100%" cellpadding="0" cellspacing="0" style="background:#0A0A0A;padding:40px 20px;">
              <tr>
                <td align="center">
                  <table width="480" cellpadding="0" cellspacing="0" style="background:#141414;border-radius:16px;padding:40px;border:1px solid #2A2A2A;">
                    <tr>
                      <td align="center" style="padding-bottom:32px;">
                        <h1 style="color:#E8B923;font-size:28px;margin:0;letter-spacing:4px;">ROUJLI</h1>
                        <p style="color:#6B6B6B;font-size:12px;margin:6px 0 0;letter-spacing:1px;">BUSINESS GROWTH OPERATING SYSTEM</p>
                      </td>
                    </tr>
                    <tr>
                      <td>
                        <h2 style="color:#FFFFFF;font-size:22px;margin:0 0 12px;">Hi ${firstName},</h2>
                        <p style="color:#9E9E9E;font-size:15px;line-height:1.6;margin:0 0 32px;">
                          We received a request to reset your ROUJLI password. Enter this code in the app:
                        </p>
                        <div style="background:#1A1A1A;border-radius:12px;padding:24px;text-align:center;margin-bottom:32px;border:1px solid #2A2A2A;">
                          <span style="color:#E8B923;font-size:40px;font-weight:bold;letter-spacing:12px;">${code}</span>
                        </div>
                        <p style="color:#6B6B6B;font-size:13px;line-height:1.5;margin:0;">
                          This code expires in <strong style="color:#9E9E9E;">10 minutes</strong>. 
                          If you didn't request a password reset, please ignore this email — your account is safe.
                        </p>
                      </td>
                    </tr>
                    <tr>
                      <td style="padding-top:32px;border-top:1px solid #2A2A2A;margin-top:32px;">
                        <p style="color:#6B6B6B;font-size:12px;text-align:center;margin:0;">
                          © 2026 ROUJLI. All rights reserved.
                        </p>
                      </td>
                    </tr>
                  </table>
                </td>
              </tr>
            </table>
          </body>
        </html>
      `,
    });
  } catch (err: any) {
    console.warn(`[SMTP Error] Could not deliver email to ${email}: ${err?.message || err}`);
    console.log(`\n==================================================`);
    console.log(`[DEV FALLBACK] Password Reset OTP for ${email} (${firstName}): ${code}`);
    console.log(`==================================================\n`);
  }
}

// ─── Send Password Change Notification Email ─────────────────────────────────

export async function sendPasswordChangeNotificationEmail(
  email: string,
  firstName: string
): Promise<void> {
  const transporter = getTransporter();

  if (!transporter) {
    console.log(`\n==================================================`);
    console.log(`[DEV FALLBACK] SMTP settings missing in .env!`);
    console.log(`[DEV FALLBACK] Password Changed Notification sent to ${email} (${firstName})`);
    console.log(`==================================================\n`);
    return;
  }

  try {
    await transporter.sendMail({
      from: FROM_EMAIL,
      to: email,
      subject: "Security Alert: Your ROUJLI password was changed",
      html: `
        <!DOCTYPE html>
        <html>
          <head>
            <meta charset="utf-8" />
            <meta name="viewport" content="width=device-width, initial-scale=1" />
          </head>
          <body style="margin:0;padding:0;background:#0A0A0A;font-family:Arial,sans-serif;">
            <table width="100%" cellpadding="0" cellspacing="0" style="background:#0A0A0A;padding:40px 20px;">
              <tr>
                <td align="center">
                  <table width="480" cellpadding="0" cellspacing="0" style="background:#141414;border-radius:16px;padding:40px;border:1px solid #2A2A2A;">
                    <tr>
                      <td align="center" style="padding-bottom:32px;">
                        <h1 style="color:#E8B923;font-size:28px;margin:0;letter-spacing:4px;">ROUJLI</h1>
                        <p style="color:#6B6B6B;font-size:12px;margin:6px 0 0;letter-spacing:1px;">BUSINESS GROWTH OPERATING SYSTEM</p>
                      </td>
                    </tr>
                    <tr>
                      <td>
                        <h2 style="color:#FFFFFF;font-size:22px;margin:0 0 12px;">Hi ${firstName},</h2>
                        <p style="color:#9E9E9E;font-size:15px;line-height:1.6;margin:0 0 24px;">
                          This email confirms that your ROUJLI account password was recently changed.
                        </p>
                        <div style="background:#1A1A1A;border-radius:12px;padding:20px;margin-bottom:24px;border:1px solid #2A2A2A;">
                          <p style="color:#E8B923;font-size:14px;font-weight:bold;margin:0 0 4px;">Security Notice</p>
                          <p style="color:#9E9E9E;font-size:13px;margin:0;">All active sessions have been signed out for security.</p>
                        </div>
                        <p style="color:#6B6B6B;font-size:13px;line-height:1.5;margin:0;">
                          If you did not perform this change, please reset your password immediately or contact ROUJLI support.
                        </p>
                      </td>
                    </tr>
                    <tr>
                      <td style="padding-top:32px;border-top:1px solid #2A2A2A;margin-top:32px;">
                        <p style="color:#6B6B6B;font-size:12px;text-align:center;margin:0;">
                          © 2026 ROUJLI. All rights reserved.
                        </p>
                      </td>
                    </tr>
                  </table>
                </td>
              </tr>
            </table>
          </body>
        </html>
      `,
    });
  } catch (err: any) {
    console.warn(`[SMTP Error] Could not deliver email to ${email}: ${err?.message || err}`);
  }
}

