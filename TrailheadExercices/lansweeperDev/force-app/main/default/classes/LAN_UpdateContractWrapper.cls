public class LAN_UpdateContractWrapper {
    @InvocableVariable(label='Updated contracts')
    public List<Contract> contracts;

    @InvocableVariable(label='Contract ID to update')
    public String contractId;

    @InvocableVariable(label='API name of the field that should be updated')
    public String fieldToUpdate;

    @InvocableVariable(label='If the previous defined field should be toggled')
    public boolean isToggleField;
}