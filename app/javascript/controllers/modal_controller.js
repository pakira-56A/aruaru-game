import { Controller } from "@hotwired/stimulus"

// <dialog> を開閉する（CSPでインラインのonclickが使えないため）
export default class extends Controller {
  static targets = ["dialog"]

  open() {
    this.dialogTarget.showModal()
  }

  close() {
    this.dialogTarget.close()
  }
}
