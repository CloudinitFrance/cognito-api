"use strict";

exports.handler = async (event, context, callback) => {
  const email = event.request.userAttributes.email;
  const name = event.request.userAttributes.name;
  const userId = event.userName;

  const templateSignUpConfirmation = (name, email, code, link) => `
  <html>
  <meta name="viewport" content="width=device-width, initial-scale=1.0" />
  <head>
    <link
      rel="stylesheet"
      href="https://fonts.googleapis.com/css?family=Open+Sans:400,600,700&display=swap"
    />
  </head>
  <body
    style="
      font-family: Open Sans, Roboto, PT Sans, Trebuchet MS, sans-serif;
      margin: 0%;
      width: 100%;
      color: #0f2978;
    "
  >
    <div
      style="
        padding: 20px;
        max-width: 600px;
        margin-left: auto;
        margin-right: auto;
      "
    >

      <h2
        style="
          font-weight: 600;
          font-size: 25px;
          line-height: 28px;
          color: #f76996;
          margin-top: 16px;
          margin-bottom: 42px;
        "
      >
        Welcome to <span style="font-weight: 700">The</span>CognitoApi
      </h2>

      <h2
        style="
          font-weight: 600;
          font-size: 20px;
          line-height: 28px;
          color: #0f2978;
          margin-top: 0px;
          margin-bottom: 8px;
        "
      >
        Hi ${name}!
      </h2>
      <div style="margin-bottom: 16px">Thank you for choosing our service.</div>

      <div style="margin-bottom: 8px">To complete your registration:</div>
      <div style="margin-bottom: 8px">
        1. Download Google Authenticator for
        <a
          href="https://play.google.com/store/apps/details?id=com.google.android.apps.authenticator2&hl=en&gl=US"
          target="_blank"
          rel="noopener noreferrer"
          style="text-decoration: none; font-weight: 600; color: #023ae0"
          >Android</a
        >
        or
        <a
          href="https://apps.apple.com/app/google-authenticator/id388497605"
          target="_blank"
          rel="noopener noreferrer"
          style="text-decoration: none; font-weight: 600; color: #023ae0"
          >iOS</a
        >
      </div>
      <div style="margin-bottom: 14px">
        2. Use this one-time password: ${code} to activate your user on the CognitoApi
      </div>

      <div style="margin-bottom: 42px">
        If you think this email cames to you by mistake, you don't have to do
        anything.
      </div>

      <hr
        style="
          margin-bottom: 16px;
          border-color: #bbc0d0;
          background: #bbc0d0;
          height: 1px;
          border: none;
        "
      />

      <div style="margin-bottom: 16px; color: #727787">
        Have questions or need help? Email us at
        <a href="mailto:tarek@tocconsulting.fr" style="display: inline-block"
          >tarek@tocconsulting.fr</a
        >
      </div>

      <div
        style="
          margin-bottom: 8px;
          font-size: 20px;
          line-height: 28px;
          color: #bbc0d0;
        "
      >
        <b>The</b>CognitoApi team
      </div>
    </div>
  </body>
</html>

`;

  const templateForgotPassword = (name, email, code, link) => `
  <h<html>
  <meta name="viewport" content="width=device-width, initial-scale=1.0" />
  <head>
    <link
      rel="stylesheet"
      href="https://fonts.googleapis.com/css?family=Open+Sans:400,600,700&display=swap"
    />
  </head>
  <body
    style="
      font-family: Open Sans, Roboto, PT Sans, Trebuchet MS, sans-serif;
      margin: 0%;
      width: 100%;
      color: #0f2978;
    "
  >
    <div
      style="
        padding: 20px;
        max-width: 600px;
        margin-left: auto;
        margin-right: auto;
      "
    >
      <h2
        style="
          font-weight: 600;
          font-size: 25px;
          line-height: 28px;
          color: #f76996;
          margin-top: 16px;
          margin-bottom: 42px;
        "
      >
        Reset Password
      </h2>

      <h2
        style="
          font-weight: 600;
          font-size: 20px;
          line-height: 28px;
          color: #0f2978;
          margin-top: 0px;
          margin-bottom: 24px;
        "
      >
        Hi ${name}!
      </h2>

      <div style="margin-bottom: 8px">
        Need to reset your password?
      </div>
      <div style="margin-bottom: 16px">
        This is your verification code:
        <span style="color: #023ae0; font-weight: 600">${code}</span>
      </div>

      <div style="margin-bottom: 8px">
        You've just requested to reset your password.
      </div>
      <div style="margin-bottom: 42px">
        If not, please contact the support immediately.
      </div>

      <hr
        style="
          margin-bottom: 16px;
          border-color: #bbc0d0;
          background: #bbc0d0;
          height: 1px;
          border: none;
        "
      />

      <div style="margin-bottom: 16px; color: #727787">
        Have questions or need help? Email us at
        <a href="mailto:tarek@tocconsulting.fr" style="display: inline-block"
          >tarek@tocconsulting.fr</a
        >
      </div>

      <div
        style="
          margin-bottom: 8px;
          font-size: 20px;
          line-height: 28px;
          color: #bbc0d0;
        "
      >
        <b>The</b>CognitoApi team
      </div>
    </div>
  </body>
</html>

`;

  if (event.triggerSource === "CustomMessage_AdminCreateUser") {
    event.response = {
      emailSubject: "Welcome to The CognitoApi",
      emailMessage: templateSignUpConfirmation(
        name,
        event.request.usernameParameter,
        event.request.codeParameter
      ),
    };
  } else if (event.triggerSource === "CustomMessage_ForgotPassword") {
    event.response = {
      emailSubject: "CognitoApi forgot password",
      emailMessage: templateForgotPassword(
        name,
        event.request.usernameParameter,
        event.request.codeParameter
      ),
    };
  }
  console.log(event.response);
  callback(null, event);
};
