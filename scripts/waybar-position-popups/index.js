#!/usr/bin/env node
const BAR_HEIGHT = 28;
require("i3wm")
  .Client.connect({ bin: "sway" })
  .then(client => {
    client.subscribe("window");
    client.on("window", ({ change, container }) => {
      if (container.app_id === "waybar" && change === "new") {
        client.command(`move position cursor`);
        client.command(`move down ${container.geometry.height / 2 + BAR_HEIGHT} px`);
      }
    });
  });
