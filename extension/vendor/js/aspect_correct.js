// john selbie 2011


// srcwidth/srcheight are the dimensions of the orignal image
// targetwidth and targetheight are the dimensions of the rendering area
// fLetterBox implies "add black bars" if true.  If false, the image is "zoomed" (cropped on one dimension) such that it fills the entire target space
// The result object returned has the following properties:
//     width: width to scale the image to
//     height: height to scale the image to
//     targetleft: position relative to the left edge of the target to center the image (can be negative when fLetterBox is false)
//     targettop: position relative to the top edge of the target to center the image (can be negative when fLetterBox is false)
function ScaleImage(srcwidth, srcheight, targetwidth, targetheight, fLetterBox) {

    var result = { width: 0, height: 0, fScaleToTargetWidth: true };

		if ((srcwidth <= 0) || (srcheight <= 0) || (targetwidth <= 0) || (targetheight <= 0)){
        return result;
    }

    // scale to the target width
    var scaleX1 = targetwidth;
    var scaleY1 = (srcheight * targetwidth) / srcwidth;

    // scale to the target height
    var scaleX2 = (srcwidth * targetheight) / srcheight;
    var scaleY2 = targetheight;

    // now figure out which one we should use
    var fScaleOnWidth = (scaleX2 > targetwidth);
    if (fScaleOnWidth) {
        fScaleOnWidth = fLetterBox;
    }
    else {
        fScaleOnWidth = !fLetterBox;
    }

    if (fScaleOnWidth) {
        result.width = Math.floor(scaleX1);
        result.height = Math.floor(scaleY1);
        result.fScaleToTargetWidth = true;
    }
    else {
        result.width = Math.floor(scaleX2);
        result.height = Math.floor(scaleY2);
        result.fScaleToTargetWidth = false;
    }
    result.targetleft 	= Math.floor((targetwidth - result.width) / 2);
    result.targettop 	= Math.floor((targetheight - result.height) / 2);

    return result;
}

function RememberOriginalSize(img) {
    if (!img.originalsize) {
        img.originalsize = {width : img.width, height : img.height};
    }
}

function FixImage(fLetterBox, div, img) {
    RememberOriginalSize(img);
    var targetwidth = $(div).width();
    var targetheight = $(div).height();
    var srcwidth = img.originalsize.width;
    var srcheight = img.originalsize.height;
    var result = ScaleImage(srcwidth, srcheight, targetwidth, targetheight, fLetterBox);
    img.width = result.width;
    img.height = result.height;
    $(img).css("left", result.targetleft);
    $(img).css("top", result.targettop);
		$(img).animate({opacity:1},250);
}

function FixImages(fLetterBox) {
    $("div.aspectcorrect").each(function (index, div) {
        var img = $(div).find("img").get(0);
        FixImage(fLetterBox, div, img);			
    });
}
window.onload = function() {
    FixImages(false);
}