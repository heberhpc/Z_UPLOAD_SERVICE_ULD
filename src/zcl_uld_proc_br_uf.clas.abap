CLASS zcl_uld_proc_br_uf DEFINITION PUBLIC FINAL CREATE PUBLIC.
  PUBLIC SECTION.
    INTERFACES: zif_data_ops_uld.

    TYPES: tt_ibge_uf TYPE STANDARD TABLE OF zbr_estados WITH EMPTY KEY.

    METHODS: parse_data IMPORTING VALUE(i_parameters) TYPE zif_data_ops_uld=>ty_method_parameters
                        RETURNING VALUE(t_uf)         TYPE tt_ibge_uf.

    METHODS: create_records IMPORTING VALUE(t_records) TYPE tt_ibge_uf
                            RETURNING VALUE(r_result)  TYPE bapiret2.

    METHODS: update_records IMPORTING VALUE(t_records) TYPE tt_ibge_uf
                            RETURNING VALUE(r_result)  TYPE bapiret2.

    METHODS: delete_records IMPORTING VALUE(t_records) TYPE tt_ibge_uf
                            RETURNING VALUE(r_result)  TYPE bapiret2.

    METHODS: reset_table RETURNING VALUE(r_result)  TYPE bapiret2.
  PROTECTED SECTION.

  PRIVATE SECTION.

ENDCLASS.
CLASS zcl_uld_proc_br_uf IMPLEMENTATION.

  """"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
  METHOD create_records.

    TRY.
        INSERT zbr_estados
          FROM TABLE @t_records.

        IF sy-subrc = 0.
          r_result-type = 'S'.
          r_result-message = 'Registros Inseridos com Sucesso'.
          RETURN.
        ELSE.
          r_result-type = 'E'.
          r_result-message = 'Erro ao inserir Registros'.
          RETURN.
        ENDIF.

      CATCH cx_sy_open_sql_db INTO DATA(exception).
        r_result-type = 'E'.
        r_result-message = exception->get_longtext(  ).
        RETURN.
    ENDTRY.

  ENDMETHOD.


  """"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
  METHOD delete_records.
    r_result = VALUE #( type = 'E' message = 'Database Operation NOT Defined' ).
  ENDMETHOD.


  """"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
  METHOD parse_data.

    DATA(lv_csv_file) = i_parameters-file_data.

    SPLIT lv_csv_file  AT cl_abap_char_utilities=>cr_lf INTO TABLE DATA(lt_file_lines).

    IF i_parameters-has_header = 'TRUE'.
      DELETE lt_file_lines INDEX 1.
    ENDIF.

    TYPES: BEGIN OF ty_raw_fields_line,
             uf_code     TYPE string,
             uf_name     TYPE string,
             capital     TYPE string,
             region_name TYPE string,
             area_km2    TYPE string,
           END OF ty_raw_fields_line.


    DATA: ls_raw_fields_line TYPE ty_raw_fields_line.
    DATA: ls_uf_line TYPE zbr_estados.

    LOOP AT lt_file_lines INTO DATA(ls_file_line).

      IF ls_file_line IS INITIAL.
        CONTINUE.
      ENDIF.

      CLEAR: ls_raw_fields_line,
             ls_uf_line.

      SPLIT ls_file_line AT ';' INTO
        ls_raw_fields_line-uf_code
        ls_raw_fields_line-uf_name
        ls_raw_fields_line-capital
        ls_raw_fields_line-region_name
        ls_raw_fields_line-area_km2.

      ls_uf_line-uf_code        = ls_raw_fields_line-uf_code.
      ls_uf_line-uf_name        = ls_raw_fields_line-uf_name.
      ls_uf_line-capital        = ls_raw_fields_line-capital.
      ls_uf_line-region_name    = ls_raw_fields_line-region_name.

      """ Resolve area.
      ls_raw_fields_line-area_km2 = replace( val =  ls_raw_fields_line-area_km2 sub = `.` with = `` occ = 0  ).
      ls_raw_fields_line-area_km2 = replace( val =  ls_raw_fields_line-area_km2 sub = `,` with = `.` occ = 0  ).
      ls_raw_fields_line-area_km2 = condense( ls_raw_fields_line-area_km2 ).

      ls_uf_line-area_km2       = ls_raw_fields_line-area_km2.

      APPEND ls_uf_line TO t_uf.

    ENDLOOP.

  ENDMETHOD.


  """"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
  METHOD zif_data_ops_uld~process_post_upload.

    " Normalize action
    i_post_parameters-db_action = to_upper( i_post_parameters-db_action ).

    CASE i_post_parameters-db_action.

      WHEN 'CREATE'.

        DATA(lt_records_create) = me->parse_data( i_parameters = i_post_parameters ).
        IF lt_records_create IS INITIAL.
          r_result = VALUE #( type = 'E' message = 'No Records to Parse or Process' ).
          RETURN.
        ENDIF.

        r_result = me->create_records( t_records = lt_records_create ).


      WHEN 'UPDATE'.

        DATA(lt_records_update) = me->parse_data( i_parameters = i_post_parameters ).
        IF lt_records_update IS INITIAL.
          r_result = VALUE #( type = 'E' message = 'No Records to Parse or Process' ).
          RETURN.
        ENDIF.

        r_result = me->update_records( t_records = lt_records_update ).

      WHEN 'DELETE'.

        DATA(lt_records_delete) = me->parse_data( i_parameters = i_post_parameters ).
        IF lt_records_delete IS INITIAL.
          r_result = VALUE #( type = 'E' message = 'No Records to Parse or Process' ).
          RETURN.
        ENDIF.

        r_result = me->delete_records( t_records = lt_records_delete ).

      WHEN 'RESET'.

        r_result = me->reset_table(  ).
        RETURN.

      WHEN 'OTHERS'.

        r_result = VALUE #( type = 'E' message = 'Database Operation NOT Defined' ).

    ENDCASE.


  ENDMETHOD.


  """"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
  METHOD reset_table.

    SELECT * FROM zbr_estados INTO TABLE @DATA(lt_ZBR_ESTADOS).

    DELETE zbr_estados FROM TABLE @lt_ZBR_ESTADOS.

    FREE: lt_ZBR_ESTADOS.
    SELECT * FROM zbr_estados INTO TABLE @lt_ZBR_ESTADOS.

    IF lt_ZBR_ESTADOS IS INITIAL.
      r_result = VALUE #( type = 'S' message = 'Tabela ZBR_ESTADOS Limpa!' ).
    ELSE.
      r_result = VALUE #( type = 'E' message = 'Erro Desconhecido ao tentar limpar tabela ZBR_ESTADOS ' ).
    ENDIF.

  ENDMETHOD.


  """"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
  METHOD update_records.
    r_result = VALUE #( type = 'E' message = 'Database Operation NOT Defined' ).
  ENDMETHOD.

ENDCLASS.
