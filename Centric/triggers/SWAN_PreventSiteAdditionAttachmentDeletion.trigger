trigger SWAN_PreventSiteAdditionAttachmentDeletion on ContentDocument (before delete) {
    
    if(Trigger.isBefore){ 
        
        if(Trigger.isDelete){ 
            SWAN_SiteAdditionFileDeletionHandler callHandlerMethod = new SWAN_SiteAdditionFileDeletionHandler(); 
            callHandlerMethod.restrictFileDeletion(Trigger.oldMap);
        }
    }
}