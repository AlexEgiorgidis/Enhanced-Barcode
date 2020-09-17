pageextension 63001 "Item Cross Reference" extends "Item Cross Reference Entries"
{
    layout
    {
        addlast(Control1)
        {
            field("Internal Barcode"; "Internal Barcode")
            {
                ApplicationArea = Basic, Suite;
                Caption = 'Internal Barcde';
            }
        }
    }
}