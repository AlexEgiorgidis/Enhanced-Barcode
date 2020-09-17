pageextension 63002 "Item List" extends "Item List"
{
    actions
    {
        addlast(navigation)
        {
            group("Barcode Mask")
            {
                action("Barcode Masks")
                {
                    ApplicationArea = Basic, Suite;
                    Image = BarCode;
                    RunObject = page "Barcode Mask Setup";
                }
            }
        }
    }
}