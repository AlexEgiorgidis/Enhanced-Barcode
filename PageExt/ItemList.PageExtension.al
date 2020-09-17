pageextension 63002 "Item List" extends "Item List"
{
    actions
    {
        addafter("Line Discounts")
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