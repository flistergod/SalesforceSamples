import { LightningElement, api, track } from "lwc";
import { getNamespaceDotNotation } from "vlocity_cmt/omniscriptInternalUtils";
import { OmniscriptBaseMixin } from "vlocity_cmt/omniscriptBaseMixin";
import template from "./swanServicePointsFromOpp.html";

export default class swanServicePointsFromOpp extends OmniscriptBaseMixin(LightningElement) {
  //for remote IP
  _actionUtil;
  _ns = getNamespaceDotNotation();

  //to render datarable when data is loaded
  isLoaded = false;

  //every @api variable comes from OS
  @api contextid;
  @api spdata;

  //dataTable
  @track errors;
  @track datalist = [];
  datalistBackUp = [];
  searchFilters = ["ServiceType", "PremiseAddress", "ServicePointNumber"];
  columns = [
    {
      fieldName: "Url",
      label: "Service Point",
      cellAttributes: { alignment: "left" },
      type: "url",
      typeAttributes: {
        label: { fieldName: "ServicePointNumber" },
        target: "_blank",
      },
      sortable: true,
      hideDefaultActions: true,
    },
    {
      fieldName: "PremiseAddress",
      label: "Premises",
      cellAttributes: { alignment: "left" },
      type: "text",
      sortable: true,
      hideDefaultActions: true,
    },
    {
      fieldName: "ServiceType",
      label: "Service",
      cellAttributes: { alignment: "left" },
      type: "text",
      sortable: true,
      hideDefaultActions: true,
    },
  ];

  connectedCallback() {
    this.populateTable();
  }

  render() {
    return template;
  }

  // Style for header
  renderedCallback() {
    //console.log(this.isRendered);
    if (this.isRendered) {
      return;
    }
    this.isRendered = true;

    let style = document.createElement("style");
    style.innerText =
      ".slds-th__action{justify-content: center;align-content: center;align-items: center; margin: auto;color: #0070d2 !important;}";
    if (this.template.querySelector(".spTable")) {
      let spTable = this.template.querySelector(".spTable");
      spTable.appendChild(style);
    }
  }

  populateTable() {
    if (this.spdata.length > 0) {
      for (let i = 0; i < this.spdata.length; i++) {
        let item = {
          ServicePointNumber: this.spdata[i].ServicePointNumber,
          PremiseAddress: this.spdata[i].PremiseAddress,
          ServiceType: this.spdata[i].ServiceType,
          Url:
            "https://" +
            window.location.hostname.split("--vlocity-cmt.visualforce.com")[0] +
            "/lightning/r/vlocity_cmt__ServicePoint__c/" +
            this.spdata[i].Id +
            "/view/",
          Id: this.spdata[i].Id,
        };
        this.datalist.push(item);
      }
      this.isLoaded = true;
      this.datalistBackUp = [...this.datalist];
      this.errors = false;
    } else {
      this.errors = true;
    }
  }
}
