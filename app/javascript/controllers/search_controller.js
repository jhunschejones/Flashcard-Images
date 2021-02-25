import { Controller } from "stimulus"

export default class extends Controller {
  static targets = [ "searchInput", "loaderWrapper" ]

  initialize() {
    // Move the cursor to the end of the input text
    this.searchInputTarget.setSelectionRange(
      this.searchInputTarget.value.length,
      this.searchInputTarget.value.length
    );
    // this.loaderWrapperTarget.classList.remove("is-active");
  }

  loading() {
    this.loaderWrapperTarget.classList.add("is-active");
    // Stop page from scrolling under spinner
    document.body.style.overflow = "hidden";
    document.body.style.height = "100vh";
  }
}
