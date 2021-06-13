$(function() {
    $("#signup").click(function(e) {
        e.preventDefault();
        $.ajax({
            url: 'signup',
            type: 'POST',
            dataType: 'json',
            data: ({
                username: $("#username").val(),
                invite: $("#invite").val(),
                email: $("#email").val()
            }),
            beforeSend: function() {
                showLoading();
            },
            complete: function(xhr, status) {
                hideLoading();
                if ( xhr.status == 201 ) {
                    showDialog({
                        title: 'Account successfully created',
                        text: 'Check your inbox!',
                        positive: {
                            title: 'Ok'
                        }
                    })
                }else if (xhr.status == 409) {
                    showDialog({
                        title: 'Username taken!',
                        text: 'This username has already been taken. Pick another.',
                        positive: {
                            title: 'Ok'
                        }
                    })
                }
            }
        });
    });
});