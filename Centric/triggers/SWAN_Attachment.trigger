trigger SWAN_Attachment on Attachment (before delete) {
	if(Trigger.isBefore ){ 
        
        if(Trigger.isdelete ){ 
            SWAN_AttachmentHandler.preventAttachmentDeletion(Trigger.oldMap);
        }
    }
}