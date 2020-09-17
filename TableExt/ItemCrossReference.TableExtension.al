tableextension 63001 "Item Cross Reference" extends "Item Cross Reference"
{

    fields
    {
        field(63000; "Internal Barcode"; boolean)
        {
            Caption = 'Internal Barcode';
            DataClassification = CustomerContent;
            Description = 'MER1.0';

            trigger OnValidate()
            Begin
            End;
        }
    }

    keys
    {
    }

    fieldgroups
    {
    }
}