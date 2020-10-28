import { Controller } from "stimulus"

export default class extends Controller {
  close(e) {
    const flash = e.target.parentNode;
    flash.parentNode.removeChild(flash);
  }
}
