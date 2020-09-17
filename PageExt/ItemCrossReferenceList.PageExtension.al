pageextension 63001 "Item Cross Reference" extends "Item Cross Reference Entries"
{
    layout
    {
        addafter("Discontinue Bar Code")
        {
            field("Internal Barcode"; "Internal Barcode")
            {
                ApplicationArea = all;
            }
        }
    }
}