// This file is automatically compiled by Webpack, along with any other files
// present in this directory. You're encouraged to place your actual application logic in
// a relevant structure within app/javascript and only use these pack files to reference
// that code so it'll be compiled.

require("@rails/ujs").start()
require("turbolinks").start()
require("@rails/activestorage").start()
require("channels")


// Uncomment to copy all static images under ../images to the output folder and reference
// them with the image_pack_tag helper in views (e.g <%= image_pack_tag 'rails.png' %>)
// or the `imagePath` JavaScript helper below.
//
// const images = require.context('../images', true)
// const imagePath = (name) => images(name, true)

import "controllers"

// https://github.com/turbolinks/turbolinks/issues/430
document.addEventListener("turbolinks:request-start", (event) => {
  const cspHeader = document.querySelector("meta[name='csp-nonce']");
  if (cspHeader != null) {
    const xhr = event.data.xhr;
    xhr.setRequestHeader("X-Turbolinks-Nonce", cspHeader.content);
  }
});
