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
            })
        });
    });
});