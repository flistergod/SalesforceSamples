trigger LAN_ContentDocumentLinkAfterInsert on ContentDocumentLink (after insert) {
    
    // Only required for notes that are linked to an account
    String s1 = String.valueof(trigger.new[0].LinkedEntityId);
    Boolean result = s1.startsWith('001');
    
    if(result)
    {
    
        //after the note is inserted, grab the Id of the new note so it can be passed to the Flow
        String noteId = trigger.new[0].ContentDocumentId;
        
        //create a new map of params to pass to the flow
        Map<String, Object> params = new Map<String, Object>();
        
        //put the params in the map
        params.put('NoteId', noteId);
        
        //create a new instance of the flow and pass the params (noteId)
        Flow.Interview.Copy_Notes_new_note Copy_Notes_new_note = new Flow.Interview.Copy_Notes_new_note(params);
        
        //start the flow
        Copy_Notes_new_note.start();
    }
}