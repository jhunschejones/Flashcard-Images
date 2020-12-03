import { Controller } from "stimulus"

export default class extends Controller {
  static targets = [ "searchInput" ]

  initialize() {
    // Move the cursor to the end of the input text
    this.searchInputTarget.setSelectionRange(
      this.searchInputTarget.value.length,
      this.searchInputTarget.value.length
    );
  }
}
