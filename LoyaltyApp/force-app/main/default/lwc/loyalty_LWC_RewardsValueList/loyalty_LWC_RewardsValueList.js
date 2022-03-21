import { LightningElement, track, api, wire } from "lwc";
import { NavigationMixin } from "lightning/navigation";
import { getListUi } from "lightning/uiListApi";
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import { refreshApex } from "@salesforce/apex";
import { getRecord } from "lightning/uiRecordApi";

//  Custom Labels import
import Loyalty_Reward_Values from "@salesforce/label/c.Loyalty_Reward_Values";
import Loyalty_Page from "@salesforce/label/c.Loyalty_Page";
import Loyalty_Of from "@salesforce/label/c.Loyalty_Of";
import Loyalty_Items from "@salesforce/label/c.Loyalty_Items";
import Loyalty_Edit from "@salesforce/label/c.Loyalty_Edit";
import Loyalty_Deactivate from "@salesforce/label/c.Loyalty_Deactivate";
import Loyalty_List_Views from '@salesforce/label/c.Loyalty_List_Views';
import Loyalty_Delete from '@salesforce/label/c.Loyalty_Delete';
import Loyalty_SelectFieldsToDisplay from '@salesforce/label/c.Loyalty_SelectFieldsToDisplay';
import Loyalty_EditListFilters from '@salesforce/label/c.Loyalty_EditListFilters';
import Loyalty_Sharing_Settings from '@salesforce/label/c.Loyalty_Sharing_Settings';
import Loyalty_rename from '@salesforce/label/c.Loyalty_rename';
import Loyalty_clone from '@salesforce/label/c.Loyalty_clone';
import Loyalty_new from '@salesforce/label/c.Loyalty_New';

import USER_ID from "@salesforce/user/Id";
import ALIAS_FIELD from "@salesforce/schema/User.Alias";
import RewardValue_OBJECT from "@salesforce/schema/Loyalty_Reward_Value__c";

import getLoyaltyRewardValueListViews from "@salesforce/apex/Loyalty_Ctrl_LoyaltyRewardValuesList.getLoyaltyRewardValueListViews";
import changeLoyaltyRewardValueField from "@salesforce/apex/Loyalty_Ctrl_LoyaltyRewardValuesList.changeLoyaltyRewardValueField";
import getListviewsLabels from "@salesforce/apex/Loyalty_Util_GenericListviewDml.getListviewsLabels";
import editistViewFilters from "@salesforce/apex/Loyalty_Util_GenericListviewDml.editistViewFilters";
import getListviewColumns from "@salesforce/apex/Loyalty_Util_GenericListviewDml.getListviewColumns";

export default class loyalty_LWC_RewardsValueList extends NavigationMixin(
  LightningElement
) {
  /* -------------------- global variables -------------------*/

  filterOptions = [];
  rewardValueColumns = [];

  label = {
    Loyalty_Delete,
    Loyalty_SelectFieldsToDisplay,
    Loyalty_EditListFilters,
    Loyalty_Sharing_Settings,
    Loyalty_rename,
    Loyalty_clone,
    Loyalty_new,
    Loyalty_List_Views,
    Loyalty_Reward_Values,
    Loyalty_Page,
    Loyalty_Of,
    Loyalty_Items,
    Loyalty_Edit,
    Loyalty_Deactivate
  };

  tableActions = [
    { label: "Show Details", name: "show_details" },
    { label: "Change Status", name: "change_status" },
    { label: "Edit", name: "edit_row" }
  ];


  defaultSortDirection = "asc";
  sortDirection = "asc";
  sortedBy;
  totalpages;
  localCurrentPage = null;
  isSearchChangeExecuted = false;
  loadMoreStatus;
  sVal = "";
  isEdit=false;

  /* -------------------- tracked variables -------------------*/

  @api rewardValueId;
  @api currentpage = 1;
  @api pagesize = 10;
  @api totalrecords;
  @api hasRecords = false;
  @api heightTable = "height: 300px";
  @api Loyalty_NoItems;
  @track searchKey = null;
  @track rewardValues = [];
  @track rewardValuesBackUp = [];
  @track isNoRewardValueListViews = true;
  @track rewardValueListViews;
  @track error;
  @track currentFilter = "AllRewardValues";
  @track currentFilterLabel = "All Reward Values";
  @track isExpanded = false;
  @track isExpandedSettings = false;
  @track isLoaded = false;
  @track recordsLoaded = false;
  @track whereClauses = [];
  @track orderByStr = "Name ";
  @track sobjectResult;
  @track listViewApiName = "AllRewardValues";
  @api showModal = false;
  @api typeOfModal;
  @track alias;
  @track wiredListviewResult;


  /* --------------------cycle methods -------------------*/

  renderedCallback() {
    this.isLoaded = true;
 }

  connectedCallback() {
    this.getListviewsLabels();
    this.getColumns();
  }

  /* -------------------- wired methods -------------------*/
  // @wire(getListUi, {
  //     objectApiName: PROGRAM_SETUP_OBJECT,
  //     listViewApiName: 'All',
  //     sortBy: NAME_FIELD,
  //     pageSize: 10
  // })
  // listView;

  @wire(getRecord, { recordId: USER_ID, fields: [ALIAS_FIELD] }) wireuser({
    error,
    data
  }) {
    if (error) {
      this.error = error;
    } else if (data) {
      this.alias = data.fields.Alias.value;
    }
  }

  @wire(getListUi, {
    objectApiName: RewardValue_OBJECT,
    listViewApiName: "$listViewApiName"
  })
  wiredlistView(result) {
    this.wiredListviewResult = result;
    if (result.data) {
      this.sobjectResult = result.data.records.records;
      //  console.log(data.records.records);

      this.loadRewardValueData(false);
    } else if (result.error) {
      this.error = result.error;
    }
  }

  @wire(getLoyaltyRewardValueListViews)
  wiredGetLoyaltyRewardValueListViews(result) {
    if (result.data) {
      this.rewardValueListViews = result.data;
      if (this.rewardValueListViews.length > 0) {
        this.isNoRewardValueListViews = false;
      } else {
        this.isNoRewardValueListViews = true;
      }
    } else {
      this.isNoRewardValueListViews = true;
    }
  }

  // @wire(getProgramSetupRules, { pagenumber: '$currentpage', pageSize: '$pagesize', searchString: '$searchKey' })
  // wiredGetProgramSetupRules(result) {
  //     if (result.data) {
  //         this.processProgramSetupRulesResult(result.data);
  //     }
  // }


    /* -------------------- getters -------------------*/
  get buttonClass() {
    if (this.isExpandedSettings) {
      return "my-icon slds-button slds-button_icon slds-button_icon-more";
    } else {
      return "slds-button slds-button_icon slds-button_icon-more";
    }
  }

  get dropdownTriggerClass() {
    if (this.isExpanded) {
      return "slds-combobox slds-dropdown-trigger slds-dropdown-trigger_click custom_list_view slds-is-open slds-size_large";
    } else {
      return "slds-combobox slds-dropdown-trigger slds-dropdown-trigger_click custom_list_view slds-size_large";
    }
  }

  get triggerDropdownSettingsIcon() {
    if (this.isExpandedSettings) {
      return "slds-dropdown-trigger slds-dropdown-trigger_click slds-is-open";
    } else {
      return "slds-dropdown-trigger slds-dropdown-trigger_click";
    }
  }

  
 
  getListviewsLabels() {
    getListviewsLabels({ ObjectType: "Loyalty_Reward_Value__c" })
      .then((result) => {
        let NewfilterOptions = [];
        let filterOption = {};

        for (let i = 0; i < result.length; i++) {
          let split = result[i].split(".");

          filterOption.label = split[0];
          filterOption.value = split[1];

          if (i == 0) {
            filterOption.selected = true;
          } else {
            filterOption.selected = false;
          }

          NewfilterOptions.push(filterOption);
          filterOption = {};
        }

        this.filterOptions = NewfilterOptions;
      })
      .catch((error) => {
        console.log(error);
      });
  }

  getColumns(isDefault) {
    this.rewardValueColumns = [
    
      {
        label: "Reward Value Id",
        fieldName: "RewardValueId",
        cellAttributes: { alignment: "left" }
      },
      {
        label: "Name",
        fieldName: "Name",
        sortable: true,
        cellAttributes: { alignment: "left" }
      },
      {
        label: "Status",
        fieldName: "Is_Delivered__c",
        sortable: true,
        type: "customLabel",
        typeAttributes: {
          labelAttributes: {
            class: "slds-text-heading_small slds-text-title_caps",
            classRules: [
              {
                value: "Active",
                class: "slds-box slds-theme_success slds-text-color_inverse"
              },
              {
                value: "Inactive",
                class: "slds-box slds-theme_offline slds-text-color_inverse"
              }
            ]
          },
          cellAttributes: { alignment: "center" }
        }
      },

      {
        label: "Promo Code",
        fieldName: "Loyalty_Reward_Value_Code__c",
        sortable: true,
        cellAttributes: { alignment: "left" }
      },
      {
        label: "Reward Type",
        fieldName: "Reward_Type__c",
        sortable: true,
        cellAttributes: { alignment: "center" }

        /*  typeAttributes: {
                labelAttributes: {
                    class: 'slds-badge slds-badge_lightest',
                    useIcon: true,
                    icon: {
                        class: 'slds-badge__icon slds-badge__icon_right',
                        position: "right",
                        name: "utility:favorite",
                        title: "Points",
                        size: "xx-small"
                    }
                }
            }*/
      },
      {
        label: "Loyalty Reward Id",
        fieldName: "Loyalty_Reward__c",
        sortable: true,
        cellAttributes: { alignment: "left" }
      },
      {
        label: "Loyalty Value Id",
        fieldName: "Loyalty_Value__c",
        sortable: true,
        cellAttributes: { alignment: "left" }
      },
      {
        label: "Created By Alias",
        fieldName: "Createdby_UserAlias",
        sortable: true,
        cellAttributes: { alignment: "left" }
      },
      {
        label: "Created Date",
        fieldName: "Created_Date"
      },
      {
        label: "Last Modified By Alias",
        fieldName: "Updatedby_UserAlias",
        sortable: true,
        cellAttributes: { alignment: "left" }
      },
      {
        label: "Last Modified Date",
        fieldName: "Last_Update"
      },

      { type: "action", typeAttributes: { rowActions: this.tableActions } }
    ];


    let listviewColumns = [];
    let newRewardColumns = [];
    //console.log('variable:' + this.listViewApiName);
    getListviewColumns({
      ObjectType: "Loyalty_Reward_Value__c",
      DeveloperName: this.listViewApiName
    })
      .then((result) => {
        listviewColumns = result;
        newRewardColumns.push(this.rewardValueColumns[0]);


        for (let i = 1; i < this.rewardValueColumns.length - 1; i++) {
          if (listviewColumns.includes(this.rewardValueColumns[i].fieldName)) {
            newRewardColumns.push(this.rewardValueColumns[i]);
          }
        }

        newRewardColumns.push(this.rewardValueColumns[this.rewardValueColumns.length-1]);
        let updatedColumns = [...newRewardColumns];

        this.rewardValueColumns = updatedColumns;
      })
      .catch((error) => {
        console.log(error);
      });
  }



  loadRewardValueData(isAddedData) {
    this.recordsLoaded = false;
    this.rewardValues = [];
    this.hasRecords = false;
    this.Loyalty_NoItems = "";
    this.isLoaded = false;

    this.totalrecords = this.sobjectResult.length;
    this.recordsLoaded = true;

    if (this.totalrecords > 0) {
      this.hasRecords = true;
      this.heightTable = "height: 700px";
    } else {
      this.hasRecords = false;
      this.Loyalty_NoItems = "No items to display.";
      this.heightTable = "height: 250px";
    }

    /*
    console.log(
      this.currentpage,
      this.totalpages,
      this.currentpage < this.totalpages
    );
    */
    if (this.currentpage < this.totalpages) {

   /*   console.log(
        this.currentpage,
        this.totalpages,
        this.currentpage < this.totalpages
      );*/
      this.currentpage = this.currentpage + 1;
    }
    this.processRewardValuesResult();
  }

  loadMoreData(event) {
 //   console.log("Load more JS made");
    if (this.rewardValues.length < this.totalrecords) {
      const { target } = event;
      target.isLoading = true;

      this.loadRewardValueData(false).then(() => {
        target.isLoading = false;
      });
    }
  }



  formatDate(unformatedDate) {
    let formatedDate = new Date(unformatedDate);
    let auxMonth = "";
    let auxDay = "";

    if (formatedDate.getMonth().toString().length <= 1) {
      auxMonth = "0";
    }
    if (formatedDate.getDate().toString().length <= 1) {
      auxDay = "0";
    }

    let formatedDate_str =
      auxDay +
      formatedDate.getDate() +
      "-" +
      auxMonth +
      (formatedDate.getMonth() + 1) +
      "-" +
      formatedDate.getFullYear();

    return formatedDate_str;
  }



  processRewardValuesResult() {
    let returnedRewardValues = this.sobjectResult;

    let preparedAssets = [];
    for (var key in returnedRewardValues) {
      let preparedAsset = {};

      try {
        preparedAsset.RewardValueId = returnedRewardValues[key].fields.Id.value;
      } catch (error) {}

      try {
        preparedAsset.Name = returnedRewardValues[key].fields.Name.value;
      } catch (error) {}

      try {
        if (returnedRewardValues[key].fields.Is_Delivered__c.value == false) {
          preparedAsset.Is_Delivered__c = "Active";
        } else {
          preparedAsset.Is_Delivered__c = "Inactive";
        }
      } catch (error) {}

      try {
        preparedAsset.Reward_Type__c =
          returnedRewardValues[key].fields.Reward_Type__c.value;
      } catch (error) {}

      try {
        preparedAsset.Loyalty_Reward__c =
          returnedRewardValues[
            key
          ].fields.Loyalty_Reward__r.value.fields.Id.value;
      } catch (error) {}

      try {
        preparedAsset.Loyalty_Reward_Value_Code__c =
          returnedRewardValues[key].fields.Loyalty_Reward_Value_Code__c.value;
      } catch (error) {}

      try {
        preparedAsset.Loyalty_Value__c =
          returnedRewardValues[
            key
          ].fields.Loyalty_Value__r.value.fields.Id.value;
      } catch (error) {}
      try {
        preparedAsset.Createdby_UserAlias =
          returnedRewardValues[key].fields.CreatedBy.value.fields.Alias.value;
      } catch (error) {}
      try {
        preparedAsset.Created_Date = this.formatDate(
          returnedRewardValues[key].fields.CreatedDate.value
        );
      } catch (error) {}
      try {
        preparedAsset.Updatedby_UserAlias =
          returnedRewardValues[
            key
          ].fields.LastModifiedBy.value.fields.Alias.value;
      } catch (error) {}
      try {
        preparedAsset.Last_Update = this.formatDate(
          returnedRewardValues[key].fields.LastModifiedDate.value
        );
      } catch (error) {}

      preparedAssets.push(preparedAsset);
    }
    let updatedRecords = [...this.rewardValues, ...preparedAssets];

    this.rewardValues = updatedRecords;
    this.rewardValuesBackUp = this.rewardValues;
  }


  updateSearchKey(event) {
    this.rewardValues = this.rewardValuesBackUp;
    this.sVal = event.target.value;

    if (this.sVal == "") {
      this.rewardValues = this.rewardValuesBackUp;
      this.hasRecords = true;
      this.Loyalty_NoItems = "";
      this.heightTable = "height: 700px";
      this.isLoaded = true;
    } else {
      let rewardValuesFiltered = [];

      for (let i = 0; i < this.rewardValues.length; i++) {
        if (this.rewardValues[i].Name.toLowerCase().includes(this.sVal.toLowerCase())){
          rewardValuesFiltered.push(this.rewardValues[i]);
        }
      }

      this.rewardValues = rewardValuesFiltered;
    }
    this.hasRecords = true;
    this.Loyalty_NoItems = "";
    this.heightTable = "height: 700px";
    this.isLoaded = true;

    if (this.rewardValues.length == 0) {
      this.hasRecords = false;
      this.Loyalty_NoItems = "No items to display.";
      this.heightTable = "height: 250px";
      this.isLoaded = false;
    }
  }

  updateValueOfField(field, fieldValue, Id, Name) {
    let title = "UPDATE SUCCESS";
    let message =
      "the Status of the record " + Name + " was updated successfully!";
    let variant = "success";
    let mode = "pester";


    changeLoyaltyRewardValueField({
      field: field,
      newFieldValue: fieldValue,
      Id: Id,
      Name: Name
    })
      .then((result) => {
        if (result == "UPDATE SUCCESS") {
          title = "Update with success";
          variant = "success";
        } else {
          title = "Update error";
          message =
            "Something went wrong while trying to update the status of the record " +
            Name;
          variant = "error";
        }

        this.toast(title, message, variant, mode);
        this.loadRewardValueData(false);
      })
      .catch((error) => {
        console.log(error);
      });
  }

  /* -------------------- DOM functions -------------------*/
  // Used to sort the column
  sortBy(field, reverse, primer) {
    console.log(field, reverse.primer);
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

  onHandleSort(event) {
    console.log(event);
    const { fieldName: sortedBy, sortDirection } = event.detail;
    const cloneData = [...this.rewardValues];

    cloneData.sort(this.sortBy(sortedBy, sortDirection === "asc" ? 1 : -1));
    this.rewardValues = cloneData;
    this.sortDirection = sortDirection;
    this.sortedBy = sortedBy;
  }

  handleLoyaltyPrevious() {
    if (this.currentpage > 1) {
      this.currentpage = this.currentpage - 1;
    }
  }
  handleLoyaltyNext() {
    if (this.currentpage < this.totalpages)
      this.currentpage = this.currentpage + 1;
  }
  handleLoyaltyFirst() {
    this.currentpage = 1;
  }
  handleLoyaltyLast() {
    this.currentpage = this.totalpages;
  }

  //filters data with filter - the new listview is the same listview but filtered
  handleFilterData(filter) {
    this.recordsLoaded = true;
    this.listViewApiName = filter;
 

    let filters = [];

    this.getColumns(false);

    switch (filter) {
      case "MyRewardValues":
        filters.push("CREATEDBY_USER.ALIAS-equals-" + this.alias);
        this.editListview(filter, filters);

        break;

      case "RecentlyViewedRewardValues":
        
        //    'CREATED_DATE greaterOrEqual 1/15/2021 12:00 AM';
        //    'CREATED_DATE lessOrEqual 1/20/2021 11:59 PM'
        let modifiedDate = new Date();
        let modifiedDateMinus6Months = new Date();
        modifiedDateMinus6Months.setMonth(modifiedDate.getMonth() + -6);

        let clauseModifiedDateMinus6Months =
          "LAST_UPDATE-greaterOrEqual-" +
          (modifiedDateMinus6Months.getMonth() + 1) +
          "/" +
          modifiedDateMinus6Months.getDate() +
          "/" +
          modifiedDateMinus6Months.getFullYear() +
          " 12:00 AM";

        let clauseModifiedDate =
          "LAST_UPDATE-lessOrEqual-" +
          (modifiedDate.getMonth() + 1) +
          "/" +
          modifiedDate.getDate() +
          "/" +
          modifiedDate.getFullYear() +
          " 11:59 PM";

        filters.push('LoyaltyCreatedDateNotEqualToLastModified__c-equals-1');
        filters.push(clauseModifiedDateMinus6Months);
        filters.push(clauseModifiedDate);
        this.editListview(filter, filters);

        break;
    }
  }

  editListview(filter, filters) {
    editistViewFilters({
      ObjectType: "Loyalty_Reward_Value__c",
      DeveloperName: filter,
      filters: filters
    })
      .then((result) => {
        if (result == "Success") {
          this.listViewApiName = filter;
        }
      })
      .catch((error) => {
        console.log(error);
      });
  }

  handleCloseModal() {
    this.showModal = false;
    this.isEdit=false;
  
  }

  handleSettingsOption(event) {
    this.typeOfModal = event.target.dataset.modaltype;
    console.log("option: " + this.typeOfModal);

    if (this.typeOfModal == "editFilters") {
      this.showModal = false;
    } else {
      this.showModal = true;

      if (this.isExpandedSettings == true) {
        console.log("option2:");
        this.isExpandedSettings = false;
      }
    }
  }

  /* -------------------- Data functions -------------------*/
  handleRowAction(event) {
    const action = event.detail.action;
    const row = event.detail.row;
    let fieldValue;
    let field = "Is_Delivered__c";
    switch (action.name) {
      case "show_details":
        this.navigateToRecordPage(row.RewardValueId);
        break;
      case "change_status":
      
        if (row.Is_Delivered__c == "Active") {
          fieldValue = true;
        } else {
          fieldValue = false;
        }
        this.updateValueOfField(field, fieldValue, row.RewardValueId, row.Name);
        refreshApex(this.wiredListviewResult);
        break;

        case "edit_row":
          this.openEditModal(row.RewardValueId);
        
        break;
    }
  }

  openEditModal(recordId) {
    this.rewardValueId=recordId;
    this.isEdit=true;
    console.log(this.isEdit);
     /*
    this[NavigationMixin.Navigate]({
      type: "standard__recordPage",
      attributes: {
        recordId: recordId,
        objectApiName: "Loyalty_Reward_Value__c",
        actionName: "view"
      }
    });
    */
    // this[NavigationMixin.GenerateUrl]({
    //     type: 'standard__recordPage',
    //     attributes: {
    //         recordId: recordId,
    //         objectApiName: 'Loyalty_Program_Setup_Rules__c',
    //         actionName: 'view'
    //     },
    // }).then(url => {
    //     window.location.replace(url);
    // });;
  }

  toast(title, message, variant, mode) {
    const toastEvent = new ShowToastEvent({
      title,
      message,
      variant,
      mode
    });
    this.dispatchEvent(toastEvent);
  }

  handleNewRewardValueCreated(event) {
    
   
    refreshApex(this.wiredListviewResult);
    
  }

  //changes the "visibility of dropdown"

  handleClickExtendOutside() {
    if (this.isExpanded == true) {
      this.isExpanded = false;
    }

    if (this.isExpandedSettings == true) {
      this.isExpandedSettings = false;
    }
  }
  handleClickExtend() {
    this.isExpanded = !this.isExpanded;
  }

  handleClickExtendSettings() {
    this.isExpandedSettings = !this.isExpandedSettings;
  }

 

  //changes listview
  handleFilterChangeButton(event) {
    this.isLoaded = false;
    let filter = event.target.dataset.filter;
    this.isExpanded = !this.isExpanded;
    this.recordsLoaded=false;

    if (filter !== this.currentFilter) {
      this.currentFilter = event.target.dataset.filter;

      for (let i = 0; i < this.filterOptions.length; i++) {
        if (this.filterOptions[i].value == this.currentFilter) {
          this.filterOptions[i].selected = true;
          this.currentFilterLabel = this.filterOptions[i].label;
        } else {
          this.filterOptions[i].selected = false;
        }
      }

      setTimeout(() => {
        this.handleFilterData(this.currentFilter), 0;
      });
    } else {
      this.isLoaded = true;
    }
  }

  HandleloadRewardValueData() {
   
    refreshApex(this.wiredListviewResult);
   
    setTimeout(() => {
      this.handleFilterData(this.currentFilter), 5000;
    });
   
  }
}