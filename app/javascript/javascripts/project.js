$(function(){
  //検索結果を表示
  const type = $('.member-list').data('type');
  let workspace_id = 0;
  let project_id = 0;
  
  $('select[name="project[workspace_id]"]').on('change', function(){
    if ($(this).val()) {
      // $('#member_search').prop('disabled', false)
      workspace_id = parseInt($(this).val(), 10);
    } else {
      $('#member_search').val('')
      workspace_id = 0
      // $('#member_search').prop('disabled', true)
    }
  });
  if (type === 'project') {
    $('select[name="project[workspace_id]"]').trigger('change')
  }

  $('select[name="board[project_id]"]').on('change', function(){
    if ($(this).val()) {
      $('#member_search').prop('disabled', false)
      project_id = parseInt($(this).val(), 10);
    } else {
      $('#member_search').val('')
      $('#member_search').prop('disabled', true)
    }
  });
  if (type === 'board') {
    $('select[name="board[project_id]"]').trigger('change')
  }

  function buildHTML_SearchResult(user){
    var html = `
      <li class="member-list__user">
        <p class="member-list__user__name">
          ${user.name}<br/>(${user.email})
        </p>
        <a class="add-member" data-user_id="${user.id}", data-user_name="${user.name}" data-user_email="${user.email}">
          追加
        </a>
      </li>
    `;
    $(".search_result").append(html);
  }
  //case no hit
  function buildHTML_SearchResult_NoHit(text){
    var html = `
      <li class="member-list__user">
          ${text}
      </li>
    `;
    $(".search_result").append(html);
  }

  $('#member_search').on('keyup', function(e){
    $(".search_result").empty();  // Initilize search_result
    const input = $('#member_search').val();

    if(input !=="" ){ //空文字対策
      let exist_user_ids = $.makeArray($('.user_ids')).map(item => parseInt(item.value));
      url = "/api/users/count";
      $.ajax({
        url: url,
        type:"GET",
        data: {keyword: input, exist_user_ids: exist_user_ids, type, project_id},
        dataType: "json",
      })
      .done(function(result){
        let display_max = 100;
        if (result.count < display_max) {
          url = "/api/users/";
          $.ajax({
            url: url,
            type: "GET",
            data: { keyword: input, exist_user_ids: exist_user_ids, type, workspace_id, project_id },
            dataType: "json",
          })
          .done(function(result){
            if(result.length !== 0){
              result.forEach(function(user){
                buildHTML_SearchResult(user);
              });
            }else{
              buildHTML_SearchResult_NoHit("一致するユーザーが見つかりません");
            }
          })
          .fail(function(){
            alert("ユーザー検索に失敗しました");
          })

        } else {
          buildHTML_SearchResult_NoHit("ヒット件数が多いため条件を変更して再度検索してください");
        }
      })
      .fail(function(){
        alert("ユーザー検索に失敗しました");
      })
    }
  })

  // Remove Member
  $(document).on('click', '.remove-member', function(e){
    e.preventDefault();
    var selected_user_id = $(this).data("user_id");
    $(this).parent().parent().remove();
    $('#member_search').trigger('keyup')
  });

  function buildHTML_AddMember (id, name, email, type) {
    let html_option = ``;
    if ($('.member-list__sel-user').length ) {
      html_option = `
        <option value="0">owner</option>
        <option value="1">manager</option>
        <option value="2" selected>regular</option>
      `;
    } else {
      html_option = `
        <option value="0" selected>owner</option>
        <option value="1">manager</option>
        <option value="2">regular</option>
      `;
    }
    
    let html = `
      <tr class="member-list__sel-user">
        <input class="user_ids" name="${type}[user_ids][]" type="hidden" value="${id}" >
        <td class="member-list__sel-user__name">
          ${name}
        </td>
        <td class="member-list__sel-user__email">
          ${email}
        </td>
        <td class="member-list__sel-user__authority">
          <select name="${type}_member[roles][]" class="form-control" >`
           + html_option + 
          `</select>
        </td>
        <td>
          <span class="remove-member" data-user_id="${id}" >削除</span>
        </td>
      </tr>
    `;
    $(".member-list tbody").append(html);
  }

  // Add member
  $(document).on("click",".add-member", function(e){
    e.preventDefault();
    const selected_user_id = $(this).data("user_id");
    const selected_user_name = $(this).data("user_name");
    const selected_user_email = $(this).data("user_email");

    if ($('.nomembers')) {
      $('.nomembers').remove();
    }

    buildHTML_AddMember(selected_user_id, selected_user_name, selected_user_email, type);
    $(this).parent().remove();
    
  });
  
});