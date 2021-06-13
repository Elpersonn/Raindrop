$(function () {
    $("#CraCCmodal").dialog({
        autoOpen: false,
        modal: true,
        resizable: false,
        buttons: {
            Ok: function () {
                $(this).dialog("close");
            }

        }
    });
    $("#ImgInfo").dialog({
        autoOpen: false,
        modal: true,
        resizable: false,
        buttons: {
            Ok: function() {
                $(this).dialog("close");
            }
        }
    });
    $("#inviteCreated").dialog({
        autoOpen: false,
        modal: true,
        resizable: false,
        width: "20%",
        height: 500
    });
    $("#error").dialog({
        autoOpen: false,
        modal: true,
        resizable: false
    });
    $("#confirm").dialog({
        autoOpen: false,
        modal: true,
        resizable: false,
        buttons: {
            No: function() {
                $(this).dialog("close");
            },
            Yes: function() {
                $(this).dialog("close");
                $.ajax({
                    url: "/admin/deluser",
                    type: "DELETE",
                    dataType: "json",
                    data: ({
                        username: $("#AccName").val()
                    }),
                    success: function(resp) {
                        var res = resp;
                        if (res.aff > 0) {
                            $("#errormsg").text("User " + $("#AccName").val() + " has been successfully deleted.");
                            $("#error").dialog("option", "title", "Success");
                            $("#error").dialog("open");
                        }
                        else {
                            $("#errormsg").text("User not found!");
                            $("#error").dialog("option", "title", "Error");
                            $("#error").dialog("open");
                        }
                    } 
                });
            }
        }
    });
    $("#send").click(function (e) {
        e.preventDefault();
        $.ajax({
            url: "/admin/createinvite",
            type: "POST",
            dataType: "json",
            data: ({
                amount: $("#amount").val() 
            }),
            success: function (response) {
                var resp = response;
                $("#invitetable tr").remove();
                $("#invitetable").append("<tr><th>Invite Code</th></tr>");

                $.each(resp.msg, function(i,v) {
                    var row = document.getElementById("invitetable").insertRow(-1);
                    var cell = row.insertCell(0);
                    cell.innerHTML = v;
                });
                $("#inviteCreated").dialog("open");
                $("#CraCCmodal").dialog("open");
            },
            error: function (xhr, text) {
                if (xhr.status == 409) {
                    $("#errormsg").text("User with that username already exists!");
                    $("#error").dialog("option", "title", "Error");
                    $("#error").dialog("open");
                }
            }
        });
    });

    $("#delimg").click(function (e) {
        e.preventDefault();
        $.ajax({
            url: "/admin/deleteimg",
            type: "DELETE",
            dataType: "json",
            data: ({
                imgurl: $("#delname").val()
            }),
            success: function (resp) {
                var res = resp;
                $("#errormsg").text("The image has been successfully deleted!\n" + resp.meta.date + "\n" + resp.meta.author);
                $("#error").dialog("option", "title", "Success");
                $("#error").dialog("open");
            }
        });
    });

    $("#Delbtn").click(function (e) {
        e.preventDefault();
        $("#text1").text("Are you sure you want to PERMAMENTLY delete user " + $("#AccName").val());
        $("#confirm").dialog("open");
    });
    $("#imginfo").click(function(e) {
        e.preventDefault();
        $.ajax({
            url: "/admin/imginfo",
            type: "GET",
            dataType: "json",
            data: ({
                imgurl: $("#delname").val()
            }),
            success: function(resp) {
                var res = resp;
                $("#uploader").text(resp.author);
                $("#date").text(resp.date);
                $("#ImgInfo").dialog("open");
            },
            statusCode: {
                404: function() {
                    $("#errormsg").text("The provided image was not found!");
                    $("#error").dialog("option", "title", "Not Found");
                    $("#error").dialog("open");
                }
            }
        });
    });
});