import { LightningElement, api } from "lwc";

export default class Trac_ModalWindow extends LightningElement {
  @api
  classNames;

  connectedCallback() {
    let cls = this.classNames;
    if (cls != null && cls.length > 0) {
      const modal = this.querySelector("[data-id=gu-modal");
      modal.classList.add(cls);
    }
  }

  @api
  toggleVisibility() {
    const modal = this.template.querySelector("[data-id=gu-modal");
    const backdrop = this.template.querySelector("[data-id=backdrop");
    modal.classList.toggle("slds-fade-in-open");
    backdrop.classList.toggle("slds-backdrop--open");
  }
}