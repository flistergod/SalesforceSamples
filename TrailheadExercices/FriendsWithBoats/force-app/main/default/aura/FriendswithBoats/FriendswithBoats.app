<!--
    page divided by 3.
    slds-col slds-size_2-of-3 - 2 out of 3
     space and then other classes from css stylesheet
     
    first 2 to search form selector and results
    third for details of tile of boat
   

    Structure:
    App invokes boatsearch

    Boatsearch includes:
     - the form with boat types and the capacity of creating a new boat record
     - the search results with the tiles corresponding to the boat type
     - each clicked tile has the boat details

    BoatSearch form has:
        -a selector with boat types
        -a button to begin query with the boat type (atribute selected in boatsearchform.cmp)
        -a button to create a new record, that calls the other url, and the type of boat is the one chosen on selector

    BoatSearchResults has:
        -tiles (img and a description with a shady layer)

    Tile has:
    By clicking in a tile, in the right side fo the Boatsearch page we have the boat details. There we have:
        -Details
        -Reviews
        -Add Reviews

    -Details has: 
        -important details
        -button with all details (1 more component?) and img
        -map

    -Review and add review not defined yet
-->

<aura:application extends="force:slds">

<lightning:layout >
  

        <div class="slds-col slds-size_2-of-3 lightingblue">
            <!--calling boatsearch with form and results-->
          <c:BoatSearch/>
          
        
        </div>

        <div class="slds-col slds-size_1-of-3">

            <c:BoatDetails/>
        </div>
 
</lightning:layout>

</aura:application>	
