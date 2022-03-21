import LightningDatatable from "lightning/datatable";

export default class customDataTable extends LightningDatatable {
  /*
   * you can detect the events after "setting up" the connected callback from the fatter but
   * You cant dispatch custom events in the extending datatable to the father,
   * so you send a message from the global window. A component in the window can
   * receive that message, as long as they are listening to the event
   * */
  connectedCallback() {
    super.connectedCallback();

    const {
      handleSelectAllRows,
      handleDeselectAllRows,
      handleSelectRow,
      handleDeselectRow,
    } = this;

    this.template.addEventListener(
      "selectallrows",
      handleSelectAllRows.bind(this)
    );

    this.template.addEventListener(
      "deselectallrows",
      handleDeselectAllRows.bind(this)
    );

    this.template.addEventListener(
      "selectrow",
      handleSelectRow.bind(this),
      true
    );

    this.template.addEventListener(
      "deselectrow",
      handleDeselectRow.bind(this),
      true
    );
  }

  disconnectedCallback() {
    super.disconnectedCallback();

    this.template.removeEventListener(
      "selectallrows",
      this.handleSelectAllRows
    );

    this.template.removeEventListener(
      "deselectallrows",
      this.handleDeselectAllRows
    );

    this.template.removeEventListener(
      "selectrow", 
      this.handleSelectRow
      );

    this.template.removeEventListener(
      "deselectrow", 
      this.handleDeselectRow
      );
  }

  handleSelectAllRows(event) {
    window.postMessage(
      {
        datarow: JSON.stringify({
          event: "selectall",
        }),
      },
      window.location.origin
    );
  }

  handleDeselectAllRows(event) {
    window.postMessage(
      {
        datarow: JSON.stringify({
          event: "deselectall",
        }),
      },
      window.location.origin
    );
  }

  findParentRow(element) {
    if (element.tagName === "TR") return element;
    return this.findParentRow(element.parentElement);
  }

  handleSelectRow(event) {
    const parentRow = this.findParentRow(event.target);
    if (parentRow) {
      window.postMessage(
        {
          datarow: JSON.stringify({
            id: parentRow.getAttribute("data-row-key-value"),
            event: "select",
          }),
        },
        window.location.origin
      );
    }
  }

  handleDeselectRow(event) {
    const parentRow = this.findParentRow(event.target);
    if (parentRow) {
      window.postMessage(
        {
          datarow: JSON.stringify({
            id: parentRow.getAttribute("data-row-key-value"),
            event: "deselect",
          }),
        },
        window.location.origin
      );
    }
  }
}
