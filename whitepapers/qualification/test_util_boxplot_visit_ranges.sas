/***
  Qualification tests for PhUSE/CSS utility macro <MACRO-NAME>

  SETUP:  Ensure that PhUSE/CSS utilities are in the AUTOCALL path

  TEST PLAN:
  https://github.com/phuse-org/phuse-scripts/blob/master/whitepapers/qualification/testplan_<MACRO-NAME>.docx
          
***/


*--- SETUP ---*;

  %let macroname = util_boxplot_visit_ranges;

  %put WARNING: (TEST_%upcase(&macroname)) User must ensure PhUSE/CSS utilities are in the AUTOCALL path.;

  /*** EXECUTE ONE TIME only as needed

    Ensure PhUSE/CSS utilities are in the AUTOCALL path
    NB: This line is not necessary if PhUSE/CSS utilities are in your default AUTOCALL paths

    OPTIONS mrecall sasautos=(%sysfunc(getoption(sasautos)) "C:\CSS\phuse-scripts\whitepapers\utilities") ls=max ps=max;

  ***/


  *--- SAVE TEST RESULTS as XML filename  ---*;
  *--- NB: if this filename is blank, do NOT save xml test results ---*;

    %let XML_FILENAME = .\outputs_sas\testresults_%lowcase(&macroname).xml;


*--- Test Definitions  ---*;
  *--- Full Specs for test definitions: https://github.com/phuse-org/phuse-scripts/blob/master/whitepapers/utilities/util_passfail.sas ---*;

  proc sql;
    create table my_test_definitions
      (  test_mac        char(32) label='Name of macro to test'
       , test_id         char(15) label="Test ID for %upcase(&macroname)"
       , test_dsc        char(80) label='Test Description'

       , test_type       char(1)  label='Test Type (Macro var, String-<B|C|L|T>, Data set, In data step)'

       , Pparm_ds        char(50) label='Test values for the Positional parameter DS'
       , Kparm_vvisn     char(50) label='Test values for the Keyword parameter VVISN'
       , Kparm_vtrtn     char(50) label='Test values for the Keyword parameter VTRTN'

       , test_expect     char(1)   label="EXPECTED test results for each call to %upcase(&macroname)"
       , test_expect_sym char(200) label='TEST_PDLIM-delim Name=Value pairs of EXPECTED global syms created'
       , test_wrap       char(120) label="Set MAX_BOXES_PER_PAGE and symdel BEFORE/AFTER each call to %upcase(&macroname)"
       , test_pdlim      char(1)   label="OVERRIDE default test delimiter (|) which %upcase(&macroname) also uses in results"
      )
    ;


    insert into my_test_definitions
      values("%lowcase(&macroname)", '2.a.1', 'numeric vars, consistent visits x treatments', 'M',   'rectangular', 'visitnum', 'treatnum',
             '', 'BOXPLOT_VISIT_RANGES=10 <= visitnum <= 13|16 <= visitnum <= 19|22 <= visitnum <= 25|28 <= visitnum <= 31|34 <= visitnum <= 37|40 <= visitnum <= 40|',
             '%GLOBAL MAX_BOXES_PER_PAGE; %LET MAX_BOXES_PER_PAGE=10; _MACCALL1_; %SYMDEL MAX_BOXES_PER_PAGE;',
             '~')
      values("%lowcase(&macroname)", '2.a.2', 'char vars, consistent visits x treatments',    'M',   'alph_rec',    'visitcd', 'treatcd',
             '', 'BOXPLOT_VISIT_RANGES="eight" <= visitcd <= "five"|"four" <= visitcd <= "nine"|"one" <= visitcd <= "seven"|"six" <= visitcd <= "ten"|"three" <= visitcd <= "two"|',
             '%GLOBAL MAX_BOXES_PER_PAGE; %LET MAX_BOXES_PER_PAGE=10; _MACCALL1_; %SYMDEL MAX_BOXES_PER_PAGE;',
             '~')

      values("%lowcase(&macroname)", '2.b.1', 'numeric vars, some missing visits & treatments', 'M',   'gaps', 'visitnum', 'treatnum',
             '', 'BOXPLOT_VISIT_RANGES=10 <= visitnum <= 13|16 <= visitnum <= 22|25 <= visitnum <= 28|31 <= visitnum <= 34|37 <= visitnum <= 40|',
             '%GLOBAL MAX_BOXES_PER_PAGE; %LET MAX_BOXES_PER_PAGE=10; _MACCALL1_; %SYMDEL MAX_BOXES_PER_PAGE;',
             '~')
      values("%lowcase(&macroname)", '2.b.2', 'char vars, some missing visits & treatments',    'M',   'alph_gap',    'visitcd', 'treatcd',
             '', 'BOXPLOT_VISIT_RANGES="eight" <= visitcd <= "five"|"four" <= visitcd <= "one"|"seven" <= visitcd <= "six"|"ten" <= visitcd <= "two"|',
             '%GLOBAL MAX_BOXES_PER_PAGE; %LET MAX_BOXES_PER_PAGE=10; _MACCALL1_; %SYMDEL MAX_BOXES_PER_PAGE;',
             '~')

/*
      values("%lowcase(&macroname)", '', '',   'M',   '', '', '',   '', 'BOXPLOT_VISIT_RANGES=')
      values("%lowcase(&macroname)", '', '',   'M',   '', '', '',   '', 'BOXPLOT_VISIT_RANGES=')
      values("%lowcase(&macroname)", '', '',   'M',   '', '', '',   '', 'BOXPLOT_VISIT_RANGES=')
      values("%lowcase(&macroname)", '', '',   'M',   '', '', '',   '', 'BOXPLOT_VISIT_RANGES=')
*/

    ;
  quit;


*--- Setup test environment here (dsets, macro vars, etc) ---*;
  data rectangular;
    *--- 44 vis*trt combinations ---*;
    do visitnum = 10 to 40 by 3;
      do treatnum = 1, 2, 3, 4;
        output;
      end;
    end;
  run;

  data gaps;
    set rectangular;

    if (13 = visitnum and 3 = treatnum) or
       (19 = visitnum and treatnum in (2, 3)) or
       (28 = visitnum and 1 = treatnum) or
       (37 = visitnum and treatnum in (3, 4)) or
       (40 = visitnum and treatnum in (1, 2))
       then delete;
  run;

  *--- TEST BEHAVIOR GIVEN ALPHANUMERIC VARS, as well ---*;
    data alph_rec;
      *--- 40 vis*trt combinations ---*;
      length visitcd $ 5;
      do visitcd = 'one', 'two', 'three', 'four', 'five', 'six', 'seven', 'eight', 'nine', 'ten';
        do treatcd = 'a1', 'a2', 'b1', 'b2';
          output;
        end;
      end;
    run;

    data alph_gap;
      set alph_rec;

      if ('two' = visitcd and 'b1' = treatcd) or
         ('four' = visitcd and treatcd in ('a2', 'b1')) or
         ('seven' = visitcd and 'a1' = treatcd) or
         ('nine' = visitcd and treatcd in ('b1', 'b2')) or
         ('ten' = visitcd and treatcd in ('a1', 'a2'))
         then delete;
    run;


*--- Create EXPECTED test results ---*;


*--- Execute & evaluate tests, and report & store test results ---*;
  %util_passfail (my_test_definitions, savexml=&xml_filename, debug=N);