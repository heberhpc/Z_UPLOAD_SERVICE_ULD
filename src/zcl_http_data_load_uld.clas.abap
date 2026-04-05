CLASS zcl_http_data_load_uld DEFINITION PUBLIC CREATE PUBLIC.
  PUBLIC SECTION.
    INTERFACES if_http_service_extension .

    METHODS: get_upload_page RETURNING VALUE(html_upload_page) TYPE string.

    METHODS process_post_data IMPORTING VALUE(i_parameters) TYPE zif_data_ops_uld=>ty_method_parameters
                              RETURNING VALUE(r_return)     TYPE bapiret2.

    METHODS: get_html_response IMPORTING VALUE(i_html_status)  TYPE string
                                         VALUE(i_html_message) TYPE string
                               RETURNING VALUE(html_page)      TYPE string.

  PROTECTED SECTION.

  PRIVATE SECTION.
    CONSTANTS: http_service_adrress TYPE string VALUE 'https://6da5c376-cfa8-4af4-913f-2061aa8356c8.abap-web.ap21.hana.ondemand.com:443/sap/bc/http/sap/',
               service_name         TYPE string VALUE 'Z_HTTP_DATA_LOAD_ULD',
               service_parameters   TYPE string VALUE '?sap-client=100'.

    DATA post_url TYPE string.

ENDCLASS.
CLASS zcl_http_data_load_uld IMPLEMENTATION.

  METHOD if_http_service_extension~handle_request.

    post_url = |{ http_service_adrress }{ service_name }{ service_parameters }|.

    DATA(http_method) = request->get_method(  ).

    CASE http_method.

      WHEN CONV string( if_web_http_client=>get ).

        " build and send the upload page
        response->set_text( me->get_upload_page(  ) ).


      WHEN CONV string( if_web_http_client=>post ).

        DATA: ls_method_parameters TYPE zif_data_ops_uld=>ty_method_parameters.

        " action
        ls_method_parameters-db_action = request->get_form_field( 'dbaction' ).

        " file content : only if operation different of "reset"
        IF ls_method_parameters-db_action <> 'reset'.
          DATA(o_mulltipart1_file) = request->get_multipart( index = 1 ). " file content : File is the first in the code
          ls_method_parameters-file_data = o_mulltipart1_file->get_text( ).
        ENDIF.

        " table name
        ls_method_parameters-table_name = request->get_form_field( 'tablename' ).

        " has Header
        ls_method_parameters-has_header = request->get_form_field( 'hasHeader' ).

        DATA(ls_process_post_result) = me->process_post_data( i_parameters = ls_method_parameters ).

        """ build response
        IF ls_process_post_result-type = 'S'.
          response->set_status( i_code = '200' i_reason = 'OK' ).
          response->set_text( get_html_response( i_html_status = 'ok' i_html_message = CONV string( ls_process_post_result-message ) ) ).
        ELSE.
          response->set_status( i_code = '400' i_reason = 'Bad Request' ).
          response->set_text( get_html_response( i_html_status = 'erro' i_html_message = CONV string( ls_process_post_result-message ) ) ).
        ENDIF.

      WHEN OTHERS.
        response->set_status( i_code = '400' i_reason = 'Bad Request' ).
        response->set_text( get_html_response( i_html_status = 'erro' i_html_message = |Método [{ http_method }] not implemented | ) ).

    ENDCASE.

  ENDMETHOD.


  """"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
  METHOD get_upload_page.

    html_upload_page =
  |<!doctype html>| &&
  |<html lang="pt-BR">| &&
  |  <head>| &&
  |    <meta charset="UTF-8" />| &&
  |    <meta name="viewport" content="width=device-width, initial-scale=1.0" />| &&
  |    <title>Upload Data Service</title>| &&
  |    <link rel="icon" href="{ post_url }" />| &&
  |    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet" />| &&
  |    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.min.css" />| &&
  |  </head>| &&
  |  <body class="bg-body-tertiary d-flex justify-content-center align-items-center" style="min-height: 100vh">| &&
  |    <div class="card border-0 shadow-sm" style="width: 100%; max-width: 520px; border-radius: 0.75rem">| &&
  |      <div class="card-header bg-white border-bottom p-3" style="border-radius: 0.75rem 0.75rem 0 0">| &&
  |        <div class="d-flex justify-content-between align-items-center">| &&
  |          <div class="d-flex align-items-center gap-3">| &&
  |            <i class="bi bi-folder2-open fs-4 text-primary"> Upload Data Service</i>| &&
  |          </div>| &&
  |        </div>| &&
  |        <div>| &&
  |          <p class="mb-0 text-muted small"></p>| &&
  |        </div>| &&
  |      </div>| &&
  |      <div class="card-body p-4">| &&
  |        <form id="form">| &&
  |          <div class="mb-4">| &&
  |            <label for="file" class="form-label small fw-medium text-secondary">| &&
  |              File <span id="req-indicator" class="text-danger">*</span></label>| &&
  |            <div class="p-3 border border-dashed rounded-3 bg-light text-center">| &&
  |              <i class="bi bi-file-earmark-arrow-up fs-2 text-secondary mb-2 d-block"></i>| &&
  |              <input type="file" id="file" required class="form-control form-control-sm bg-white" />| &&
  |            </div>| &&
  |          </div>| &&
  |          <div class="mb-4 form-check form-switch">| &&
  |            <input type="checkbox" class="form-check-input" id="hasHeader" name="hasHeader" />| &&
  |            <label class="form-check-label small fw-medium text-secondary" for="hasHeader">File Has Header ? </label>| &&
  |          </div>| &&
  |          <div class="mb-4">| &&
  |            <label for="tablename" class="form-label small fw-medium text-secondary">Table Name</label>| &&
  |            <div class="input-group input-group-sm">| &&
  |              <span class="input-group-text bg-white border-end-0 text-muted"><i class="bi bi-tag"></i></span>| &&
  |              <input type="text" id="tablename" name="tablename" placeholder="Ex: Z_FI_CLIENTES" required class="form-control border-start-0 ps-1" />| &&
  |            </div>| &&
  |          </div>| &&
  |          <div class="mb-5">| &&
  |            <label class="form-label small fw-medium text-secondary">Action Type</label>| &&
  |            <div class="btn-group w-100 shadow-sm" role="group">| &&
  |              <input type="radio" class="btn-check" name="dbaction" id="create" value="create" checked autocomplete="off" />| &&
  |              <label class="btn btn-outline-primary btn-sm py-2" for="create"> <i class="bi bi-plus-lg me-1"></i> Create </label>| &&
  |              <input type="radio" class="btn-check" name="dbaction" id="update" value="update" autocomplete="off" />| &&
  |              <label class="btn btn-outline-success btn-sm py-2" for="update"> <i class="bi bi-arrow-repeat me-1"></i> Update </label>| &&
  |              <input type="radio" class="btn-check" name="dbaction" id="delete" value="delete" autocomplete="off" />| &&
  |              <label class="btn btn-outline-danger btn-sm py-2" for="delete"> <i class="bi bi-trash3 me-1"></i> Delete </label>| &&
  |              <input type="radio" class="btn-check" name="dbaction" id="reset" value="reset" autocomplete="off" />| &&
  |              <label class="btn btn-outline-warning btn-sm py-2" for="reset"> <i class="bi bi-eraser me-1"></i> Reset </label>| &&
  |            </div>| &&
  |          </div>| &&
  |          <div class="d-flex justify-content-end gap-2 border-top pt-4">| &&
  |            <button type="submit" class="btn btn-primary btn-sm px-4 shadow-sm fw-medium">| &&
  |              <i class="bi bi-cloud-upload me-2"></i>Execute Action| &&
  |            </button>| &&
  |          </div>| &&
  |        </form>| &&
  |      </div>| &&
  |    </div>| &&
  |    <script>| &&
  |      const fileInput = document.getElementById("file");| &&
  |      const reqIndicator = document.getElementById("req-indicator");| &&
  |      const radioButtons = document.querySelectorAll('input[name="dbaction"]');| &&
  |      radioButtons.forEach((radio) => \{| &&
  |        radio.addEventListener("change", function () \{| &&
  |          if (this.value === "reset") \{| &&
  |            fileInput.required = false;| &&
  |            fileInput.value = "";| &&
  |            if (reqIndicator) reqIndicator.style.display = "none";| &&
  |          \} else \{| &&
  |            fileInput.required = true;| &&
  |            if (reqIndicator) reqIndicator.style.display = "inline";| &&
  |          \}| &&
  |        \});| &&
  |      \});| &&
  |      document.getElementById("form").addEventListener("submit", function (e) \{| &&
  |        e.preventDefault();| &&
  |        const userFile = document.getElementById("file").files[0];| &&
  |        const tableName = document.getElementById("tablename").value;| &&
  |        const hasHeader = document.getElementById("hasHeader").checked;| &&
  |        const selectedAction = document.querySelector('input[name="dbaction"]:checked').value;| &&
  |        const formData = new FormData();| &&
  |        if (selectedAction !== "reset") \{| &&
  |          formData.append("user-file", userFile, "user_file");| &&
  |        \}| &&
  |        formData.append("tablename", tableName);| &&
  |        formData.append("hasHeader", hasHeader);| &&
  |        formData.append("dbaction", selectedAction);| &&
  |        fetch(| &&
  |          "{ post_url }",| &&
  |          \{ method: "POST", body: formData \},| &&
  |        )| &&
  |          .then((res) => res.text())| &&
  |          .then((data) => \{| &&
  |            document.body.innerHTML = data;| &&
  |          \})| &&
  |          .catch((err) => console.log(err));| &&
  |      \});| &&
  |    </script>| &&
  |  </body>| &&
  |</html>| .

  ENDMETHOD.



  """"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
  METHOD process_post_data.


    "Normalize parameters"
    i_parameters-db_action = to_upper( i_parameters-db_action ).
    i_parameters-has_header = to_upper( i_parameters-has_header ).
    i_parameters-table_name = to_upper( i_parameters-table_name ).


    CASE i_parameters-table_name.

      WHEN 'ZTCIDADES_IBGE'.

        DATA(o_ztcidades_ibge) = NEW lcl__handler_ztcidades_ibge( ).
        r_return = o_ztcidades_ibge->zif_data_ops_uld~process_post_upload( i_post_parameters = i_parameters ).
        RETURN.

      WHEN 'ZBR_ESTADOS'.

        r_return = VALUE #( type = |E|
                         message = |No process defined for the table: { i_parameters-table_name }| ).

      WHEN OTHERS.

    ENDCASE.


  ENDMETHOD.


  """"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
  METHOD get_html_response.

    "values ​​for ERROR"
    CONSTANTS : titulo_erro    TYPE string VALUE 'Erro',
                subtitulo_erro TYPE string VALUE 'Falha na operação',
                cor_erro       TYPE string VALUE '#f8d7da'.


    " Values ​​for SUCCESS
    CONSTANTS: titulo_sucesso    TYPE string VALUE 'Sucesso',
               subtitulo_sucerro TYPE string VALUE 'Operação Concluida',
               cor_sucesso       TYPE string VALUE '#d1e7dd'.

    "values ​​to hide / show icon"
    CONSTANTS: icon_visible TYPE string VALUE 'block',
               icon_hidden  TYPE string VALUE 'none'.

    DATA: lv_status_icon_ok   TYPE string,
          lv_status_icon_erro TYPE string,
          lv_titulo           TYPE string,
          lv_subtitulo        TYPE string,
          lv_cor              TYPE string.

    CASE i_html_status.

      WHEN 'ok'.

        lv_status_icon_ok = icon_visible.
        lv_status_icon_erro = icon_hidden.
        lv_titulo = titulo_sucesso.
        lv_subtitulo = subtitulo_sucerro.
        lv_cor = cor_sucesso.

      WHEN 'erro'.

        lv_status_icon_ok = icon_hidden.
        lv_status_icon_erro = icon_visible .
        lv_titulo = titulo_erro.
        lv_subtitulo = subtitulo_erro.
        lv_cor = cor_erro.

      WHEN OTHERS.

        lv_status_icon_ok = icon_hidden.
        lv_status_icon_erro = icon_visible .
        lv_titulo = titulo_erro.
        lv_subtitulo = subtitulo_erro.
        lv_cor = cor_erro.

    ENDCASE.

    html_page =
  |<!DOCTYPE html>| &&
  |<html lang="pt-BR">| &&
  |<head>| &&
  |    <meta charset="UTF-8">| &&
  |    <meta name="viewport" content="width=device-width, initial-scale=1.0">| &&
  |    <title>Resultado</title>| &&
  |    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">| &&
  |</head>| &&
  |<body class="bg-light d-flex justify-content-center align-items-center" style="min-height: 100vh;">| &&
  |    <div class="card" style="width: 100%; max-width: 460px; border-radius: 12px;">| &&
  |        <div class="card-body p-4">| &&
  |            <div class="d-flex align-items-center gap-2 mb-4">| &&
  |                <div id="header-icon" class="rounded-2 d-flex align-items-center justify-content-center"| &&
  |                    style="width:36px; height:36px; background-color:{ lv_cor }; flex-shrink:0;">| &&
  |                    <svg id="icon-ok" xmlns="http://www.w3.org/2000/svg" width="18" height="18" fill="none"| &&
  |                        viewBox="0 0 24 24" stroke="#0f5132" stroke-width="2.2" style="display:{ lv_status_icon_ok }">| &&
  |                        <path stroke-linecap="round" stroke-linejoin="round" d="M5 13l4 4L19 7" />| &&
  |                    </svg>| &&
  |                    <svg id="icon-erro" xmlns="http://www.w3.org/2000/svg" width="18" height="18" fill="none"| &&
  |                        viewBox="0 0 24 24" stroke="#842029" stroke-width="2.2" style="display:{ lv_status_icon_erro }">| &&
  |                        <path stroke-linecap="round" stroke-linejoin="round" d="M6 18L18 6M6 6l12 12" />| &&
  |                    </svg>| &&
  |                </div>| &&
  |                <div>| &&
  |                    <h6 id="titulo" class="mb-0 fw-medium">{ lv_titulo }</h6>| &&
  |                    <p id="subtitulo" class="mb-0 text-muted" style="font-size: 12px;">{ lv_subtitulo }</p>| &&
  |                </div>| &&
  |            </div>| &&
  |            | &&
  |            <div class="mb-4 p-3 rounded-2 bg-light border">| &&
  |                <p class="mb-1 text-muted"| &&
  |                    style="font-size: 11px; font-weight: 500; text-transform: uppercase; letter-spacing: .05em;">| &&
  |                </p>| &&
  |                <p id="mensagem" class="mb-0" style="font-size: 14px;">{ i_html_message }</p>| &&
  |            </div>| &&
  |            <div class="d-grid">| &&
  |                <button class="btn btn-primary btn-sm" style="padding: 8px; border-radius: 8px;"| &&
  |                    onclick="window.location.href='{ post_url }'">Voltar</button>| &&
  |            </div>| &&
  |        </div>| &&
  |    </div>| &&
  |</body>| &&
  |</html>|.

  ENDMETHOD.

ENDCLASS.
