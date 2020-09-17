codeunit 63000 "Barcode Management"
{
    // version MER1.0

    trigger OnRun()
    begin
    end;

    var
        BarcMask: Record "Barcode Mask";
        BarcMaskChar: Record "Barcode Mask Character";
        BarcodeType: Text[30];
        Cchar: Text[1];
        Ichar: Text[1];
        Lchar: Text[1];
        Mchar: Text[1];
        NSchar: Text[1];
        Schar: Text[1];
        Tchar: Text[1];
        VChar: Text[1];
        Xchar: Text[1];
        Inum: Integer;
        Ipos: Integer;
        Mpos: Integer;
        NSnum: Integer;
        NSPos: Integer;
        BarcodeMask: Boolean;
        BarEan: Boolean;
        DoNotAskForConfirmation: Boolean;
        EANBarcode: Boolean;
        RetailVariants: Boolean;
        Text004: Label 'Length of the barcode is greater than the length of the %1.';
        Text005: Label 'The Item No. is only %1 digits long according to the %2.\';
        Text006: Label 'Enter just the Item No. or the full barcode with or without the check digit.';
        Text007: Label 'Enter just the Item No. or the full barcode';
        Text012: Label 'Character %1 in the %2 is invalid.';
        Text015: Label 'Character number %1 must be %2.';
        Text020: Label 'Incorrect barcode type.';
        Text021: Label 'The length of barcode is not correct.';
        Text022: Label 'The barcode is not correct. Check Digit should be %1.';
        Text036: Label 'Length of a standard EAN barcode mask must be 13.';
        Text042: Label 'Item No. must be continuous in the mask.';
        Text043: Label 'The mask is not a standard 13 digit EAN mask, it cannot have a check digit.';
        Text044: Label 'Modulus Check Digit must be digit no. %1 in the mask.';
        Text045: Label 'Character %1 is not registered in the %2 table.';
        Text046: Label 'Character number %1 in the mask must be a modulus check digit - %2.';
        Text048: Label 'Not all %2s are represented by a %1 in the %3 table.';
        Text061: Label 'Number Series must be continuous in the mask.';
        Text062: Label 'Use number series masks to construct barcodes.';

    procedure CheckBarcode(var BarcodeNo: Code[22]; var Item: Record Item)
    var
        MaskSegment: Record "Barcode Mask Segment";
        CalcBarcode: Code[22];
        PriceInBarcode: Boolean;
        QtyInBarcode: Boolean;
        UOM: Code[10];
        ConfirmText: Text[50];
        i: Integer;
        ConfirmDialogueActive: Boolean;
        CreateEmbeddedBarcode: Boolean;
    begin
        ConfirmDialogueActive := true;
        if StrLen(BarcodeNo) = 13 then
            if FindBarcodeMask(BarcodeNo, BarcMask) then begin
            end;

        RetailVariants := false;
        BarEanBarcodeMaskUse(Item);
        if BarEan then begin
            if BarcodeMask then begin
                ConstructBarcode(BarcodeNo, Item);
                CalcBarcode := BarcodeNo;
            end else begin
                if CopyStr(BarcodeNo, 1, 2) <> '20' then
                    case StrLen(BarcodeNo) of
                        6:
                            if CopyStr(BarcodeNo, 1, 1) = '0' then
                                BarcodeType := '1'                                  // UPC-E code(1)
                            else
                                if CopyStr(BarcodeNo, 1, 1) = '2' then
                                    BarcodeType := '2'                                // price in barode (2)
                                else
                                    BarcodeType := '98';                              // error (98)
                        7:
                            if CopyStr(BarcodeNo, 1, 1) = '0' then
                                BarcodeType := '1'                                  // UPC-E code(1)
                            else
                                if Code2Int(CopyStr(BarcodeNo, 1, 2)) >= 30 then
                                    BarcodeType := '3'                                // ean 8 code (3)
                                else
                                    BarcodeType := '98';                              // error (98)
                        8:
                            if CopyStr(BarcodeNo, 1, 1) = '0' then
                                BarcodeType := '1'
                            else
                                if Code2Int(CopyStr(BarcodeNo, 1, 2)) >= 30 then
                                    BarcodeType := '3'                                  // ean 8 code(3)
                                else
                                    BarcodeType := '98';                                // error (98)
                        11:
                            if CopyStr(BarcodeNo, 1, 1) = '0' then
                                BarcodeType := '4'                                 // UPC-A code(4)
                            else
                                BarcodeType := '98';                               // error (98)
                        12:
                            if CopyStr(BarcodeNo, 1, 1) = '0' then
                                BarcodeType := '4'                                 // UPC-A Code(4)
                            else
                                if Code2Int(CopyStr(BarcodeNo, 1, 2)) >= 30 then
                                    BarcodeType := '5'                               // ean 13 (5)
                                else
                                    BarcodeType := '98';                             // error (98)
                        13:
                            if (Code2Int(CopyStr(BarcodeNo, 1, 2)) >= 30) or (Code2Int(CopyStr(BarcodeNo, 1, 2)) <= 13) then
                                BarcodeType := '5'                                 // ean 13 code(5)
                            else
                                if CopyStr(BarcodeNo, 1, 1) = '2' then
                                    BarcodeType := '2'                               // price in barode (2)
                                else
                                    BarcodeType := '98';                             // error (98)
                        1 .. 5, 9, 10, 14 .. 22:
                            BarcodeType := '99';                                 // error (99)
                    end;

                if CopyStr(BarcodeNo, 1, 2) = '20' then
                    if (StrLen(BarcodeNo) = 12) or (StrLen(BarcodeNo) = 13) then   // instorecode
                        BarcodeType := '5'
                    else
                        BarcodeType := '99';
                CalcBarcode := BarcodeNo;
            end;

            if BarcodeType = '2' then
                CalcBarcode := CalcBarcode + '0'
            else
                FindCheckDigit(CalcBarcode);

            BarcodeNo := CalcBarcode;
        end else begin
            if BarcodeMask then
                ConstructBarcode(BarcodeNo, Item);

        end;
    end;

    procedure ConstructBarcode(var BarcodeNo: Code[22]; Item: Record Item)
    var
        TempBarcode: Code[22];
        MaskChar: Text[1];
        i: Integer;
        j: Integer;
        NoSeriesMgt: Codeunit NoSeriesManagement;
        NoSeriesUsed: Code[20];
        lMask: Record "Barcode Mask";
        SeriesNumber: Code[20];
        BarcodeMaskCharacter: Record "Barcode Mask Character";
    begin
        CalcMask(Item."Barcode Mask");
        TempBarcode := '';
        if StrLen(BarcodeNo) > StrLen(Item."Barcode Mask") then
            Error(Text004, Item.FieldCaption("Barcode Mask"));

        if (BarEan and (StrLen(BarcodeNo) < StrLen(Item."Barcode Mask") - 1)) or
              (not BarEan and (StrLen(BarcodeNo) < StrLen(Item."Barcode Mask")))
        then begin
            i := 1;
            repeat
                MaskChar := CopyStr(Item."Barcode Mask", i, 1);
                case MaskChar of
                    Ichar:
                        begin
                            if StrLen(BarcodeNo) > Inum then
                                if BarEan then
                                    Error(Text005 + Text006, Inum, Item.FieldCaption("Barcode Mask"))
                                else
                                    Error(Text005 + Text007, Inum, Item.FieldCaption("Barcode Mask"));
                            TempBarcode := TempBarcode + CopyStr('0000000000000000000000', 1, Inum - StrLen(BarcodeNo)) + BarcodeNo;
                            i := i + Inum;
                            BarcodeNo := '';
                        end;
                    '0' .. '9':
                        begin
                            TempBarcode := TempBarcode + MaskChar;
                            i := i + 1;
                        end;
                    Mchar:
                        begin
                            if BarcodeNo = '' then
                                if BarcodeMaskCharacter.Get(BarcodeMaskCharacter."Character Type"::"Check Digit") then
                                    TempBarcode := TempBarcode + BarcodeMaskCharacter.Character;

                            i := i + 1;
                        end;
                    NSchar:
                        if BarcodeNo <> '' then begin
                            TempBarcode := TempBarcode + CopyStr(BarcodeNo, i, 1);
                            i := i + 1;
                        end else begin
                            j := i;
                            repeat
                                i := i + 1;
                                MaskChar := CopyStr(Item."Barcode Mask", i, 1);
                            until MaskChar <> NSchar;
                            lMask.SetCurrentKey(Mask);
                            lMask.SetRange(Mask, Item."Barcode Mask");
                            lMask.FindFirst;
                            NoSeriesUsed := '';
                            NoSeriesMgt.InitSeries(lMask."Number Series", '', 0D, SeriesNumber, NoSeriesUsed);
                            TempBarcode := TempBarcode + SeriesNumber;
                        end;
                    else
                        Error(Text012, MaskChar, Item.FieldCaption("Barcode Mask"));
                end;
            until i = StrLen(Item."Barcode Mask") + 1;
            if RetailVariants then
                BarcodeNo := ''
            else
                BarcodeNo := TempBarcode;
        end else begin
            i := 1;
            repeat
                MaskChar := CopyStr(Item."Barcode Mask", i, 1);
                case MaskChar of
                    Xchar, Ichar, Mchar:
                        begin
                            TempBarcode := TempBarcode + CopyStr(BarcodeNo, i, 1);
                            i := i + 1;
                        end;
                    '0' .. '9':
                        begin
                            if CopyStr(BarcodeNo, i, 1) <> MaskChar then
                                Error(Text015, i, MaskChar);
                            TempBarcode := TempBarcode + CopyStr(BarcodeNo, i, 1);
                            i := i + 1;
                        end;
                    NSchar:
                        begin
                            TempBarcode := TempBarcode + CopyStr(BarcodeNo, i, 1);
                            i := i + 1;
                        end;
                    else
                        Error(Text012, MaskChar, Item.FieldCaption("Barcode Mask"));
                end;
            until i = StrLen(Item."Barcode Mask") + 1;
            if RetailVariants then
                BarcodeNo := ''
            else
                BarcodeNo := TempBarcode;
        end;
    end;

    procedure FindCheckDigit(var BarcodeNo: Code[22])
    begin
        FindCheckDigitEx(BarcodeNo, BarcodeType);
    end;

    procedure CheckItemMask(Mask: Code[22]; Item: Record Item)
    begin
        BarEanUseItem(Item);
        CheckMaskChar(Mask);
    end;

    procedure CheckMaskChar(Mask: Code[22])
    var
        LastPos: Text[1];
        i: Integer;
        Char: Text[1];
    begin
        if BarEan then
            if StrLen(Mask) <> 13 then
                Error(Text036);
        LastPos := '';
        InitMaskCharacters;
        for i := 1 to StrLen(Mask) do begin
            Char := CopyStr(Mask, i, 1);
            case Char of
                '0' .. '9', Xchar:
                    LastPos := Char;
                Ichar:
                    if Ipos = 0 then begin
                        LastPos := Char;
                        Ipos := i;
                    end else
                        if LastPos <> Char then
                            Error(Text042);
                NSchar:
                    if NSPos = 0 then begin
                        LastPos := Char;
                        NSPos := i;
                    end else
                        if LastPos <> Char then
                            Error(Text061);
                Mchar:
                    begin
                        if not BarEan then
                            Error(Text043);
                        if i <> Mpos then
                            Error(Text044, Mpos);
                        LastPos := Char;
                    end;
                else
                    Error(Text045, Char, BarcMaskChar.TableCaption);
            end;
        end;
        if BarEan then
            if StrPos(Mask, Mchar) = 0 then
                Error(Text046, Mpos, Mchar);
    end;

    procedure CalcMask(Mask: Code[22])
    var
        i: Integer;
        Char: Text[1];
    begin
        InitMaskCharacters;
        for i := 1 to StrLen(Mask) do begin
            Char := CopyStr(Mask, i, 1);
            case Char of
                Ichar:
                    begin
                        Inum := Inum + 1;
                        if Ipos = 0 then
                            Ipos := i;
                    end;
                NSchar:
                    begin
                        NSnum := NSnum + 1;
                        if NSPos = 0 then
                            NSPos := i;
                    end;
            end;
        end;
    end;

    procedure InitMaskCharacters()
    var
        MaskChar: array[20] of Text[1];
        i: Integer;
    begin
        for i := 0 to 3 do begin
            if not BarcMaskChar.Get(i) then
                Error(
                    Text048,
                    BarcMaskChar.FieldCaption(Character), BarcMaskChar.FieldCaption("Character Type"),
                    BarcMaskChar.TableCaption);
            MaskChar[i + 1] := BarcMaskChar.Character;
        end;

        Ichar := MaskChar[1]; // Item No.
        Xchar := MaskChar[2]; // Any Char.
        Mchar := MaskChar[3]; // Check Digit
        NSchar := 'N';//MaskChar[4]; // Number Series

        Ipos := 0;
        Mpos := 13;

        Inum := 0;
    end;

    procedure BarEanBarcodeMaskUse(Item: Record Item)
    begin
        BarEan := true;
        BarcodeMask := true;
    end;

    procedure BarEanUseItem(Item: Record Item)
    begin
        BarEan := true;
    end;

    procedure FindBarcodeMask(Barcode: Code[22]; var BarCodeMask: Record "Barcode Mask"): Boolean
    begin
        //FindBarcodeMask
        BarCodeMask.Reset;
        BarCodeMask.SetCurrentKey(Mask);
        if not BarCodeMask.RecordLevelLocking then begin
            BarCodeMask.SetFilter(Mask, '<=%1', Barcode + 'A');
            if BarCodeMask.FindLast then
                if CopyStr(Barcode, 1, StrLen(BarCodeMask.Prefix)) = BarCodeMask.Prefix then begin
                    BarCodeMask.CalcFields(Length);
                    exit(true);
                end;
        end else begin
            BarCodeMask.SetFilter(Mask, '%1..', Barcode);
            if BarCodeMask.FindFirst then
                if CopyStr(Barcode, 1, StrLen(BarCodeMask.Prefix)) = BarCodeMask.Prefix then begin
                    BarCodeMask.CalcFields(Length);
                    exit(true);
                end;
        end;
        Clear(BarCodeMask);
        exit(false);
    end;

    procedure RetBarcodeFromNoSeries(Item: Record Item) NewBarcode: Code[22]
    var
        BarcodeMask_l: Record "Barcode Mask";
    begin
        //RetBarcodeFromNoSeries

        Item.TestField("Barcode Mask");
        CalcMask(Item."Barcode Mask");
        if NSnum = 0 then
            Error(Text062);

        NewBarcode := '';
        if Item."Barcode Mask" <> '' then begin
            BarcodeMask_l.Reset;
            BarcodeMask_l.SetCurrentKey(Mask);
            BarcodeMask_l.SetRange(Mask, Item."Barcode Mask");
            if BarcodeMask_l.FindFirst then
                NewBarcode := RetBarcodeFromNoSeriesEx(Item, BarcodeMask_l);
        end;
    end;

    procedure RetBarcodeFromNoSeriesEx(pItem: Record Item; pMask: Record "Barcode Mask") NewBarcode: Code[22]
    var
        BarcodeMaskCharacter: Record "Barcode Mask Character";
        NoSeriesMgt: Codeunit NoSeriesManagement;
        NoSeriesUsed: Code[20];
        LengthOfNoSeriesField: Integer;
        I: Integer;
        NoSeriesCharacter: Code[1];
        CheckDigitCharacter: Code[1];
        EANLicenseCharacter: Code[1];
        LengthOfEANLicenseField: Integer;
        EANLicBeforeNumSeries: Boolean;
        EanLic: Text[30];
    begin
        //RetBarcodeFromNoSeriesEx
        NewBarcode := '';

        if pMask."Number Series" <> '' then begin
            NoSeriesCharacter := '';
            CheckDigitCharacter := '';
            if BarcodeMaskCharacter.Get(BarcodeMaskCharacter."Character Type"::"Number Series") then
                NoSeriesCharacter := BarcodeMaskCharacter.Character;
            if BarcodeMaskCharacter.Get(BarcodeMaskCharacter."Character Type"::"Check Digit") then
                CheckDigitCharacter := BarcodeMaskCharacter.Character;
            LengthOfNoSeriesField := 0;
            for I := 1 to StrLen(pMask.Mask) do begin
                if CopyStr(pMask.Mask, I, 1) = NoSeriesCharacter then
                    LengthOfNoSeriesField := LengthOfNoSeriesField + 1;
                if CopyStr(pMask.Mask, I, 1) = EANLicenseCharacter then begin
                    LengthOfEANLicenseField := LengthOfEANLicenseField + 1;
                    if LengthOfNoSeriesField = 0 then
                        EANLicBeforeNumSeries := true
                    else
                        EANLicBeforeNumSeries := false;
                end;
            end;
            NoSeriesUsed := '';
            NoSeriesMgt.InitSeries(pMask."Number Series", '', 0D, NewBarcode, NoSeriesUsed);
            if StrLen(NewBarcode) <> LengthOfNoSeriesField then begin
                NewBarcode := '';
                exit;
            end;
            EanLic := '';
            if EANLicenseCharacter <> '' then
                if EANLicBeforeNumSeries then
                    NewBarcode := pMask.Prefix + EanLic + NewBarcode
                else
                    NewBarcode := pMask.Prefix + NewBarcode + EanLic
            else
                NewBarcode := pMask.Prefix + NewBarcode;
            DoNotAskForConfirmation := true;
            if pMask.Symbology in [pMask.Symbology::EAN13, pMask.Symbology::EAN8] then
                EANBarcode := true
            else
                EANBarcode := false;
            CheckBarcode(NewBarcode, pItem);
            if (StrLen(NewBarcode) < StrLen(pMask.Mask)) and (CopyStr(pMask.Mask, StrLen(pMask.Mask), 1) = CheckDigitCharacter) and EANBarcode
            then begin
                if StrLen(NewBarcode) = 7 then
                    BarcodeType := '3'
                else
                    BarcodeType := '5';
                FindCheckDigit(NewBarcode);
            end;
        end;
    end;

    procedure ConstructBarcodeFromMask(pMask: Record "Barcode Mask"): Code[22]
    var
        lItem_tmp: Record Item temporary;
        lBarcode: Code[22];
        BarcodeMaskCharacter: Record "Barcode Mask Character";
    begin
        lBarcode := '';
        lItem_tmp."Barcode Mask" := pMask.Mask;
        CalcMask(lItem_tmp."Barcode Mask");
        if Inum <> 0 then
            Error(Text012 + '\' + Text062, Ichar, lItem_tmp.FieldCaption("Barcode Mask"));
        ConstructBarcode(lBarcode, lItem_tmp);
        DoNotAskForConfirmation := true;
        if StrLen(lBarcode) > 1 then begin
            BarcodeMaskCharacter.Reset;
            BarcodeMaskCharacter.SetCurrentKey(Character);
            BarcodeMaskCharacter.SetRange(Character, CopyStr(lBarcode, StrLen(lBarcode), 1));
            if BarcodeMaskCharacter.FindFirst then
                if BarcodeMaskCharacter."Character Type" = BarcodeMaskCharacter."Character Type"::"Check Digit" then begin
                    lBarcode := CopyStr(lBarcode, 1, StrLen(lBarcode) - 1);
                    FindCheckDigitEx(lBarcode, '5');
                end;
        end;
        CheckBarcode(lBarcode, lItem_tmp);

        exit(lBarcode);
    end;

    procedure FindCheckDigitEx(var BarcodeNo: Code[22]; pBarcodeType: Text[30])
    var
        Chk: Integer;
        Char: Text[1];
    begin
        if pBarcodeType = '98' then
            Error(Text020);
        if (BarcodeNo = '') or (pBarcodeType = '99') then
            Error(Text021);

        if pBarcodeType = '1' then begin
            Chk := 1 + StrCheckSum(CopyStr(BarcodeNo, 1, 6), '131313');
            Char := SelectStr(Chk, '0,1,2,3,4,5,6,7,8,9');
            if StrLen(BarcodeNo) = 6 then
                BarcodeNo := BarcodeNo + Char;
            if Char <> CopyStr(BarcodeNo, 7, 1) then
                Error(Text022, Char);
            exit;
        end;

        if pBarcodeType = '3' then begin
            Chk := 1 + StrCheckSum(CopyStr(BarcodeNo, 1, 7), '3131313');
            Char := SelectStr(Chk, '0,1,2,3,4,5,6,7,8,9');
            if StrLen(BarcodeNo) = 7 then
                BarcodeNo := BarcodeNo + Char;
            if Char <> CopyStr(BarcodeNo, 8, 1) then
                Error(Text022, Char);
            exit;
        end;

        if pBarcodeType = '4' then begin
            Chk := 1 + StrCheckSum(CopyStr(BarcodeNo, 1, 11), '31313131313');
            Char := SelectStr(Chk, '0,1,2,3,4,5,6,7,8,9');
            if StrLen(BarcodeNo) = 11 then
                BarcodeNo := BarcodeNo + Char;
            if Char <> CopyStr(BarcodeNo, 12, 1) then
                Error(Text022, Char);
            exit;
        end;

        if pBarcodeType = '5' then begin
            Chk := 1 + StrCheckSum(CopyStr(BarcodeNo, 1, 12), '131313131313');
            Char := SelectStr(Chk, '0,1,2,3,4,5,6,7,8,9');
            if StrLen(BarcodeNo) = 12 then
                BarcodeNo := BarcodeNo + Char;
            if Char <> CopyStr(BarcodeNo, 13, 1) then
                Error(Text022, Char);
            exit;
        end;
    end;

    procedure Code2Int(pCode: Code[10]): Integer
    var
        xInt: Integer;
    begin
        if not Evaluate(xInt, pCode) then
            xInt := 0;
        exit(xInt);
    end;

    procedure GetBarcodeTypeEPL(BarcodeNo: Code[20]): Code[3]
    var
        BarcodeType_l: Code[3];
    begin
        if CopyStr(BarcodeNo, 1, 2) <> '20' then
            case StrLen(BarcodeNo) of
                6:
                    if CopyStr(BarcodeNo, 1, 1) = '0' then
                        BarcodeType_l := 'UE0'                                // UPC-E code(1)
                    else
                        BarcodeType_l := '1';                                 // Code 128
                7:
                    if CopyStr(BarcodeNo, 1, 1) = '0' then
                        BarcodeType_l := 'UE0'                                // UPC-E code(1)
                    else
                        if Code2Int(CopyStr(BarcodeNo, 1, 2)) >= 30 then
                            BarcodeType_l := 'E80'                              // EAN 8 code (3)
                        else
                            BarcodeType_l := '1';                               // Code 128
                8:
                    if CopyStr(BarcodeNo, 1, 1) = '0' then
                        BarcodeType_l := 'UE0'                                // UPC-E code(1)
                    else
                        if Code2Int(CopyStr(BarcodeNo, 1, 2)) >= 30 then
                            BarcodeType_l := 'E80'                              // EAN 8 code(3)
                        else
                            BarcodeType_l := '1';                               // Code 128
                11:
                    if CopyStr(BarcodeNo, 1, 1) = '0' then
                        BarcodeType_l := 'UA0'                               // UPC-A code(4)
                    else
                        BarcodeType_l := '1';                                // Code 128
                12:
                    if CopyStr(BarcodeNo, 1, 1) = '0' then
                        BarcodeType_l := 'UA0'                               // UPC-A Code(4)
                    else
                        if Code2Int(CopyStr(BarcodeNo, 1, 2)) >= 30 then
                            BarcodeType_l := 'E30'                             // EAN 13 (5)
                        else
                            BarcodeType_l := '1';                              // Code 128
                13:
                    if (Code2Int(CopyStr(BarcodeNo, 1, 2)) >= 30) or (Code2Int(CopyStr(BarcodeNo, 1, 2)) <= 13) then
                        BarcodeType_l := 'E30'                               // EAN 13 code(5)
                    else
                        if CopyStr(BarcodeNo, 1, 1) <> '2' then
                            BarcodeType_l := '1';                              // Code 128
                1 .. 5, 9, 10, 14 .. 22:
                    BarcodeType_l := '1';                                  // Code 128
            end;

        if BarcodeType_l = '' then
            BarcodeType_l := '1';

        if CopyStr(BarcodeNo, 1, 2) = '20' then
            if (StrLen(BarcodeNo) = 12) or (StrLen(BarcodeNo) = 13) then   // instorecode
                BarcodeType_l := 'E30'
            else
                BarcodeType_l := '1';

        exit(BarcodeType_l);
    end;
}

