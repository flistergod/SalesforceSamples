import { LightningElement, api, track } from "lwc";
import template from "./doPagination.html";
import { OmniscriptBaseMixin } from "vlocity_cmt/omniscriptBaseMixin";
import { getNamespaceDotNotation } from "vlocity_cmt/omniscriptInternalUtils";
import { OmniscriptActionCommonUtil } from "vlocity_cmt/omniscriptActionUtils";
import { ShowToastEvent } from "lightning/platformShowToastEvent";

const DELAY = 300;

export default class DoPaginaton extends OmniscriptBaseMixin(LightningElement) {
  //for remote IP
  _actionUtil;
  _ns = getNamespaceDotNotation();

  @api showTable = false;
  @api records;
  @api recordsperpage;
  @api columns;
  @api searchFilters;
  @api contextid;

  @track draftValues = [];
  @track recordsToDisplay;
  @track selectedRows = [];

  SelectedSpIdsArray = [];
  pickedPage;
  numRow = "5";
  searchValue = "";
  recordsBackUp = [];
  totalRecords;
  pageNo;
  totalPages;
  startRecord;
  endRecord;
  end = false;
  pagelinks = [];
  isLoading = false;
  defaultSortDirection = "asc";
  sortDirection = "asc";
  sortedBy;
  messageHandler;
  gasSize = 0;
  elecSize = 0;
  allRecordsSize = 0;
  map = {};

  /*-------------------Cycle Methos--------------------------- */
  render() {
    return template;
  }

  connectedCallback() {
    this.setupEventListeners();
    this.recordsBackUp = this.records;
    this.fillMap();
    this.isLoading = true;
    this.allRecordsSize = this.records.length;
    this.setRecordsToDisplay();
  }

  //map of id and servicetype of sp's. Used when selecting sps to increase counters
  fillMap() {
    for (let i = 0; i < this.records.length; i++) {
      let _id = this.records[i]["Id"];
      let _serviceType = this.records[i]["ServiceType"];

      this.map[_id] = _serviceType;
    }
  }

  //remove costum events from component
  disconnectedCallback() {
    window.removeEventListener("message", this.messageHandler);
  }

  //receive the costum events
  setupEventListeners() {
    //handle received event
    this.messageHandler = ({ data, origin }) => {
      if (origin === window.location.origin) {
        if (data.datarow) {
          let jsondata = JSON.parse(data.datarow);

          if (jsondata.event == "select") {
            this.SelectedSpIdsArray.push(jsondata.id);

            if (this.map[jsondata.id] == "Gas") {
              this.gasSize++;
              console.log("gas " + this.gasSize);
            }

            if (this.map[jsondata.id] == "Electricity") {
              this.elecSize++;
              console.log("gas " + this.gasSize);
            }
          }
          if (jsondata.event == "selectall") {
            this.handleSelectAllRows();
          }
          if (jsondata.event == "deselectall") {
            this.handleDeselectAllRows();
          }

          if (jsondata.event == "deselect") {
            for (let j = 0; j < this.SelectedSpIdsArray.length; j++) {
              if (this.SelectedSpIdsArray[j] == jsondata.id) {
                this.SelectedSpIdsArray.splice(j, 1);
              }
            }

            if (this.map[jsondata.id] == "Gas") {
              this.gasSize--;
            }

            if (this.map[jsondata.id] == "Electricity") {
              this.elecSize--;
            }
          }

          this.getSelectedRows();
        }
      }
    };
    //add costum events to window
    window.addEventListener("message", this.messageHandler);
  }

  //handle costum event from costum datatable
  handleSelectAllRows(event) {
    this.selectedRows = [];

    if (this.searchValue == "") {
      for (let j = 0; j < this.recordsBackUp.length; j++) {
        if (!this.SelectedSpIdsArray.includes(this.recordsBackUp[j].Id)) {
          this.SelectedSpIdsArray.push(this.recordsBackUp[j].Id);
        }
      }
    } else {
      for (let j = 0; j < this.records.length; j++) {
        if (!this.SelectedSpIdsArray.includes(this.records[j].Id)) {
          this.SelectedSpIdsArray.push(this.records[j].Id);
        }
      }
    }

    for (let j = 0; j < this.SelectedSpIdsArray.length; j++) {
      if (this.map[this.SelectedSpIdsArray[j]] == "Gas") {
        this.gasSize++;
      }

      if (this.map[this.SelectedSpIdsArray[j]] == "Electricity") {
        this.elecSize++;
      }
    }

    this.getSelectedRows();
  }

  //handle costum event from costum datatable
  handleDeselectAllRows(event) {
    this.elecSize = 0;
    this.gasSize = 0;
    this.selectedRows = [];
    if (this.searchValue == "") {
      this.SelectedSpIdsArray = [];
    } else {
      for (let j = 0; j < this.SelectedSpIdsArray.length; j++) {
        for (let p = 0; p < this.records.length; p++) {
          if (this.records[p].Id == this.SelectedSpIdsArray[j]) {
            this.SelectedSpIdsArray.splice(j, 1);
          }
        }
      }
    }
    this.getSelectedRows();
  }

  //get the arrray of ids that are currently selected on that page
  getSelectedRows() {
    this.selectedRows = [];

    for (let i = 0; i < this.recordsToDisplay.length; i++) {
      if (this.SelectedSpIdsArray.includes(this.recordsToDisplay[i].Id)) {
        this.selectedRows.push(this.recordsToDisplay[i].Id);
      }
    }
  }

  //options of number of records per page
  get rowOptions() {
    return [
      { label: "5", value: "5" },
      { label: "10", value: "10" },
      { label: "15", value: "15" },
    ];
  }

  /*changes number of rows per page given the input on the dropdown*/
  changeNumRows(event) {
    this.numRow = event.detail.value;
    this.recordsperpage = this.numRow;
    this.isLoading = true;
    this.setRecordsToDisplay();
  }

  /*distributes all the records per page*/
  setRecordsToDisplay() {
    let linkCount = 0;
    this.pagelinks = [];
    this.totalRecords = this.records.length;
    this.pageNo = 1;
    this.totalPages = Math.ceil(this.totalRecords / this.recordsperpage);
    this.preparePaginationList();

    if (this.totalPages >= 3) {
      linkCount = 3;
    } else {
      linkCount = this.totalPages;
    }

    for (let i = 1; i <= linkCount; i++) {
      this.pagelinks.push(i);
    }
    this.isLoading = false;
  }

  /*checks which pagination button was pressed */
  handleClick(event) {
    let label = event.target.label;
    if (label === "First") {
      this.handleFirst();
    } else if (label === "Previous") {
      this.handlePrevious();
    } else if (label === "Next") {
      this.handleNext();
    } else if (label === "Last") {
      this.handleLast();
    }
  }

  //this.pagelinks is an array with 3 elements, becuase I only want 3 page numbers showing up (the squares on the html)
  //handles navigation when pressing "next"
  handleNext() {
    if (this.totalPages > 3) {
      if (this.pageNo + 1 == this.totalPages) {
        this.pagelinks = [this.pageNo - 1, this.pageNo, this.pageNo + 1];
      } else {
        this.pagelinks = [this.pageNo, this.pageNo + 1, this.pageNo + 2];
      }
    }

    this.pageNo += 1;
    this.preparePaginationList();
  }

  //handles navigation when pressing "previous"
  handlePrevious() {
    if (this.totalPages > 3) {
      if (this.pageNo - 1 == 1) {
        this.pagelinks = [this.pageNo - 1, this.pageNo, this.pageNo + 1];
      } else {
        this.pagelinks = [this.pageNo - 2, this.pageNo - 1, this.pageNo];
      }
    }

    this.pageNo -= 1;
    this.preparePaginationList();
  }

  //handles navigation when pressing "first"
  handleFirst() {
    this.pageNo = 1;
    if (this.totalPages > 3) {
      this.pagelinks = [this.pageNo, this.pageNo + 1, this.pageNo + 2];
    }

    this.preparePaginationList();
  }

  //handles navigation when pressing "last"
  handleLast() {
    this.pageNo = this.totalPages;
    if (this.totalPages > 3) {
      this.pagelinks = [this.pageNo - 2, this.pageNo - 1, this.pageNo];
    }

    this.preparePaginationList();
  }

  //loads the correct records on that page
  preparePaginationList() {
    this.isLoading = true;
    let begin = (this.pageNo - 1) * parseInt(this.recordsperpage);
    let end = parseInt(begin) + parseInt(this.recordsperpage);
    this.recordsToDisplay = this.records.slice(begin, end);
    this.getSelectedRows();

    this.startRecord = begin + parseInt(1);
    this.endRecord = end > this.totalRecords ? this.totalRecords : end;
    this.end = end > this.totalRecords ? true : false;

    const event = new CustomEvent("pagination", {
      detail: {
        records: this.recordsToDisplay,
      },
    });
    // this.dispatchEvent(event);

    window.clearTimeout(this.delayTimeout);
    this.delayTimeout = setTimeout(() => {
      this.disableEnableActions();
    }, DELAY);
    this.isLoading = false;
  }

  //makes a button disabled when required
  disableEnableActions() {
    let buttons = this.template.querySelectorAll("lightning-button");

    buttons.forEach((bun) => {
      if (bun.label === this.pageNo) {
        bun.disabled = true;
      } else {
        bun.disabled = false;
      }

      if (bun.label === "First") {
        bun.disabled = this.pageNo === 1 ? true : false;
      } else if (bun.label === "Previous") {
        bun.disabled = this.pageNo === 1 ? true : false;
      } else if (bun.label === "Next") {
        bun.disabled = this.pageNo === this.totalPages ? true : false;
      } else if (bun.label === "Last") {
        bun.disabled = this.pageNo === this.totalPages ? true : false;
      }
    });
  }

  //calls IP to refresh sp industry data
  invokeIP(JsonSpIds) {
    this._actionUtil = new OmniscriptActionCommonUtil();

    this.IPInput = { ContextId: this.contextid, spIds: JsonSpIds };

    const options = {};

    const params = {
      input: JSON.stringify(this.IPInput),
      sClassName: `${this._ns}IntegrationProcedureService`,
      sMethodName: "Account_SWAN_Industry_Data_Refresh",
      options: JSON.stringify(options),
    };
    this.isLoading = true;
    this._actionUtil
      .executeAction(params, null, this, null, null)
      .then((response) => {
        this.isLoading = false;
        this.dispatchEvent(
          new ShowToastEvent({
            title: "Success",
            message: "All Service Points will be updated, once notified",
            variant: "success",
          })
        );
      })
      .catch((error) => {
        console.error(error, "ERROR");
      });
  }

  //prepares data to be used on IP above
  handleRefresh() {
    let spIds_Gas_array = [];
    let spIds_Elec_array = [];
    let spIds;

    try {
      for (let k = 0; k < this.SelectedSpIdsArray.length; k++) {
        for (let l = 0; l < this.recordsBackUp.length; l++) {
          if (this.recordsBackUp[l].Id == this.SelectedSpIdsArray[k]) {
            if (this.recordsBackUp[l].ServiceType == "Gas") {
              spIds_Gas_array.push(this.recordsBackUp[l].Id);
            }
            if (this.recordsBackUp[l].ServiceType == "Electricity") {
              spIds_Elec_array.push(this.recordsBackUp[l].Id);
            }
            break;
          }
        }
      }
    } catch (error) {
      console.log(error);
    }

    if (spIds_Gas_array.length == 0 && spIds_Elec_array == 0) {
      this.dispatchEvent(
        new ShowToastEvent({
          title: "Error",
          message: "Select at least 1 Service Point to update",
          variant: "error",
        })
      );
    } else {
      spIds = {
        spIds_Gas: spIds_Gas_array,
        spIds_Elec: spIds_Elec_array,
      };

      this.invokeIP(spIds);

      console.log(spIds);
    }

    this.omniApplyCallResp(spIds);
  }

  /*updates the page to go to*/
  updatePickedPage(event) {
    this.pickedPage = parseInt(event.target.value);
    //console.log(this.pickedPage);

    if (this.pickedPage <= 1 || this.pickedPage > this.totalPages) {
      this.pickedPage = 1;
    }
  }

  /*handles the navigation to the chosen page*/
  goToPage() {
    this.pageNo = this.pickedPage;

    if (this.totalPages > 3) {
      if (this.pageNo == this.totalPages) {
        this.pagelinks = [this.pageNo - 2, this.pageNo - 1, this.pageNo];
      } else if (this.pageNo == 1) {
        this.pagelinks = [this.pageNo, this.pageNo + 1, this.pageNo + 2];
      } else {
        this.pagelinks = [this.pageNo - 1, this.pageNo, this.pageNo + 1];
      }
    }

    this.preparePaginationList();
  }

  /*navigates to page when pressing one of the 3 numbers */
  handlePage(button) {
    this.pageNo = button.target.label;

    if (this.totalPages > 3) {
      if (this.pageNo == this.totalPages) {
        this.pagelinks = [this.pageNo - 2, this.pageNo - 1, this.pageNo];
      } else if (this.pageNo == 1) {
        this.pagelinks = [this.pageNo, this.pageNo + 1, this.pageNo + 2];
      } else {
        this.pagelinks = [this.pageNo - 1, this.pageNo, this.pageNo + 1];
      }
    }

    this.preparePaginationList();
  }

  /** sorts columns */
  onHandleSort(event) {
    const { fieldName: sortedBy, sortDirection } = event.detail;
    const cloneData = [...this.recordsToDisplay];
    cloneData.sort(this.sortBy(sortedBy, sortDirection === "asc" ? 1 : -1));
    this.recordsToDisplay = cloneData;
    this.getSelectedRows();

    this.sortDirection = sortDirection;
    this.sortedBy = sortedBy;
  }

  sortBy(field, reverse, primer) {
    const key = primer
      ? function (x) {
          return primer(x[field]);
        }
      : function (x) {
          return x[field];
        };

    return function (a, b) {
      a = key(a);
      b = key(b);
      return reverse * ((a > b) - (b > a));
    };
  }

  /**updates the inserted word to filter the table */
  updateKey(event) {
    this.searchValue = event.target.value;

    if (this.searchValue == "") {
      this.isLoading = true;
      this.records = this.recordsBackUp;
      this.setRecordsToDisplay();
      this.isLoading = false;
    }
  }

  /**filters the table with the given word */
  handleSearch() {
    this.records = this.recordsBackUp;

    let recordsFiltered = [];
    this.isLoading = true;

    let filterColumns = this.searchFilters;

    for (let i = 0; i < this.records.length; i++) {
      let validRecord = 0;

      for (let j = 0; j < filterColumns.length; j++) {
        if (this.records[i][filterColumns[j]] != undefined) {
          if (
            this.records[i][filterColumns[j]]
              .toLowerCase()
              .includes(this.searchValue.toLowerCase())
          ) {
            validRecord++;
          }
        }
      }

      if (validRecord > 0) {
        recordsFiltered.push(this.records[i]);
      }
    }

    this.records = recordsFiltered;
    this.setRecordsToDisplay();
    this.isLoading = false;
  }
}
