table 63000 "Barcode Mask"
{
    // version MER1.0

    DataClassification = CustomerContent;
    Caption = 'Barcode Mask';
    DataCaptionFields = Description;
    DrillDownPageId = 63002;
    LookupPageId = 63002;

    fields
    {
        field(1; "Entry No."; Integer)
        {
            DataClassification = CustomerContent;
            Caption = 'Entry No.';
        }
        field(5; Mask; Code[22])
        {
            DataClassification = CustomerContent;
            Caption = 'Mask';

            trigger OnValidate()
            var
                BarcMask: Record "Barcode Mask";
            begin
                if (Mask <> '') and (Mask <> xRec.Mask) then begin
                    BarcMask.SetCurrentKey(Mask);
                    BarcMask.SetRange(Mask, Mask);
                    BarcMask.SetFilter("Entry No.", '<>%1', "Entry No.");
                    if BarcMask.Find('-') then
                        Error(Text000 + ' ' + Mask + Text001);
                    CreateSegments;
                end;
                UpdateMask;
            end;
        }
        field(10; Description; Text[50])
        {
            DataClassification = CustomerContent;
            Caption = 'Description';
        }
        field(15; Type; Option)
        {
            DataClassification = CustomerContent;
            Caption = 'Type';
            OptionCaption = ' ,Item';
            OptionMembers = " ","Item";
            InitValue = "Item";
        }
        field(20; Length; Decimal)
        {
            CalcFormula = sum ("Barcode Mask Segment".Length where("Mask Entry No." = field("Entry No.")));
            Caption = 'Length';
            DecimalPlaces = 0 : 0;
            Editable = false;
            FieldClass = FlowField;
        }
        field(25; Prefix; Text[22])
        {
            DataClassification = CustomerContent;
            Caption = 'Prefix';

            trigger OnValidate()
            begin
                if Prefix <> '' then begin
                    tmpMask.Reset;
                    tmpMask.SetCurrentKey(Prefix);
                    tmpMask.SetFilter("Entry No.", '<>%1', "Entry No.");
                    if tmpMask.Find('-') then
                        repeat
                            if (tmpMask.Prefix <> '') and (CopyStr(tmpMask.Prefix, 1, StrLen(Prefix)) = Prefix) or
                                  (tmpMask.Prefix <> '') and (CopyStr(Prefix, 1, StrLen(tmpMask.Prefix)) = tmpMask.Prefix) then
                                Error(StrSubstNo(Text002, TableCaption));
                        until tmpMask.Next = 0;
                end;
                UpdateMask;
                if (Prefix = '') and (Mask <> '') then
                    Error(Text005);
            end;
        }
        field(30; Symbology; Option)
        {
            DataClassification = CustomerContent;
            Caption = 'Symbology';
            OptionCaption = 'EAN13,EAN8,UPCA,UPCE,CODE39,CODE128,PDF417,MAXICODE,CODE128_A,CODE128_B,CODE128_C';
            OptionMembers = EAN13,EAN8,UPCA,UPCE,CODE39,CODE128,PDF417,MAXICODE,CODE128_A,CODE128_B,CODE128_C;
        }
        field(35; "Number Series"; Code[20])
        {
            DataClassification = CustomerContent;
            Caption = 'Number Series';
            TableRelation = "No. Series".Code;
        }
    }

    keys
    {
        key(Key1; "Entry No.")
        {
            Clustered = true;
        }
        key(Key2; Mask)
        {
        }
        key(Key3; Prefix)
        {
        }
    }

    fieldgroups
    {
    }

    trigger OnDelete()
    begin
        Segm.Reset;
        Segm.SetRange("Mask Entry No.", "Entry No.");
        Segm.DeleteAll(true);
    end;

    trigger OnInsert()
    begin
        if "Entry No." = 0 then
            UpdateEntryNo;
    end;

    trigger OnModify()
    begin
        UpdateMask;
    end;

    var
        tmpMask: Record "Barcode Mask";
        Segm: Record "Barcode Mask Segment";
        BarcodeMaskChar: Record "Barcode Mask Character";
        Text000: Label 'Barcode mask:';
        Text001: Label ' exists already';
        Text002: Label '%1 must be uniquely identifiable.';
        Text003: Label '%1 exist for this %2';
        Text004: Label 'Character %1 is not specified in %2';
        Text005: Label 'Prefix is missing';

    procedure UpdateMask()
    var
        Str: Code[22];
    begin
        Mask := Prefix;
        Segm.Reset;
        Segm.SetRange("Mask Entry No.", "Entry No.");
        if Segm.Find('-') then
            repeat
                if Segm.Char <> '' then
                    Mask := Mask + PadStr(Str, Segm.Length, Segm.Char);
            until Segm.Next = 0;
    end;

    procedure UpdateEntryNo()
    begin
        tmpMask.Reset;
        tmpMask.LockTable;
        if tmpMask.Find('+') then
            "Entry No." := tmpMask."Entry No." + 1
        else
            "Entry No." := 1;
    end;

    procedure CreateSegments()
    var
        SubStr: Text[30];
        MChar: Text[1];
        SLength: Integer;
        SNo: Integer;
        srcMask: Code[22];
    begin
        if "Entry No." = 0 then
            UpdateEntryNo;

        srcMask := Mask;
        Segm.Reset;
        Segm.SetRange("Mask Entry No.", "Entry No.");
        if Segm.Find('-') then
            Error(StrSubstNo(Text003, Segm.TableCaption, TableCaption));

        SNo := 1;
        while (CopyStr(srcMask, SNo, 1) <> '') and (IsCharNumber(CopyStr(srcMask, SNo, 1))) do
            SNo := SNo + 1;

        Validate(Prefix, CopyStr(srcMask, 1, SNo - 1));

        BarcodeMaskChar.SetCurrentKey(Character);
        SubStr := CopyStr(srcMask, StrLen(Prefix) + 1, 22);
        Segm."Mask Entry No." := "Entry No.";
        SNo := 1;
        while SubStr <> '' do begin
            MChar := CopyStr(SubStr, 1, 1);
            BarcodeMaskChar.SetRange(Character, MChar);
            if not BarcodeMaskChar.Find('-') then
                if IsCharNumber(MChar) then
                    BarcodeMaskChar."Character Type" := BarcodeMaskChar."Character Type"::"Any No."
                else
                    Error(StrSubstNo(Text004, MChar, BarcodeMaskChar.TableCaption));
            SLength := 1;
            while CopyStr(SubStr, SLength + 1, 1) = MChar do
                SLength := SLength + 1;
            Segm."Segment No" := SNo;
            Segm.Length := SLength;
            Segm.Type := BarcodeMaskChar."Character Type";
            Segm.Char := MChar;
            Segm.Insert;
            SNo := SNo + 1;
            SubStr := CopyStr(SubStr, SLength + 1, 22);
        end;
        UpdateMask;
        Validate(Prefix, Prefix);
    end;

    procedure GetRefLength(): Integer
    begin
        case Symbology of
            Symbology::EAN13:
                exit(13);
            Symbology::EAN8:
                exit(8);
            Symbology::UPCA:
                exit(12);
            Symbology::UPCE:
                exit(7);
        end;

        exit(0);
    end;

    procedure IsCharNumber(pChar: Code[1]): Boolean
    var
        Number: Integer;
    begin
        if Evaluate(Number, pChar) then
            exit(true)
        else
            exit(false);
    end;
}

