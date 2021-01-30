/* I know what I'm doing, right? */
user_pref("browser.aboutConfig.showWarning", false);
/* Enable chrome/userChrome.css */
user_pref("toolkit.legacyUserProfileCustomizations.stylesheets", true);
/* Sync server */
user_pref("identity.sync.tokenserver.uri", "https://fxsync.app.alebastr.su/token/1.0/sync/1.5");
/* This button is annoying. */
user_pref("media.videocontrols.picture-in-picture.video-toggle.enabled", false);
/* speech-dispatcher */
user_pref("media.webspeech.synth.enabled", false);

user_pref("widget.allow-client-side-decoration", true);
/* Allow system theme colors in tree-style-tab */
// user_pref("widget.content.allow-gtk-dark-theme", false);
/* Enable WebRender and other wayland tweaks */
user_pref("gfx.webrender.all", true);
/* Tab and new page settings */
user_pref("browser.ctrlTab.recentlyUsedOrder", false);
user_pref("browser.newtabpage.enabled", false);
user_pref("browser.startup.homepage", "about:blank");
user_pref("browser.startup.page", 3);
/* Disable builtin password manager */
user_pref("signon.rememberSignons", false);
/* Privacy.
 * See also: https://github.com/arkenfox/user.js/blob/master/user.js
 */
user_pref("app.shield.optoutstudies.enabled", false);
user_pref("browser.discovery.enabled", false);
user_pref("datareporting.healthreport.uploadEnabled", false);
user_pref("datareporting.policy.dataSubmissionEnabled", false);
user_pref("toolkit.telemetry.coverage.opt-out", true);
user_pref("toolkit.coverage.opt-out", true);
user_pref("toolkit.coverage.endpoint.base", "");
user_pref("toolkit.telemetry.unified", false);
user_pref("toolkit.telemetry.enabled", false);
user_pref("toolkit.telemetry.archive.enabled", false);
user_pref("toolkit.telemetry.newProfilePing.enabled", false);
user_pref("toolkit.telemetry.shutdownPingSender.enabled", false);
user_pref("toolkit.telemetry.updatePing.enabled", false);
user_pref("toolkit.telemetry.bhrPing.enabled", false);
user_pref("toolkit.telemetry.firstShutdownPing.enabled", false);
