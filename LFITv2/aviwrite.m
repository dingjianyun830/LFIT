function [vidobj] = aviwrite(frame,cMap,codec,vidobj,filename,frameInd,quality,fpsVal,totalFrames)
% writeavi | Writes the current frame to a new or existing AVI file
%   
% Supports multiple MATLAB versions, but be careful of
% codec/compression/output format differences between versions of MATLAB
% older than R2010b and newer versions.

if verLessThan('matlab', '7.11') % lower MATLAB versions don't support VideoWriter, but do support avifile
    switch codec
        case 0
            comp='None';
        case 1
            comp='MSVC';
        case 2
            comp='RLE';
        case 3
            comp='Cinepak';
        otherwise
            error('Invalid codec/compression selection in requestVector input to movie generating function.');
    end
    if frameInd==1
        try
            vidobj = avifile(filename,'compression',comp);
        catch err
            warning('Program was improperly closed during last AVI write.');
            clear mex % this may have greater scope than intended; uncertain of extent of behavior when calling this. It should close any open AVI files though.
            try
                vidobj = avifile(filename,'compression',comp);
            catch err2
                rethrow(err);
            end
        end
        vidobj.colormap = colormap(cMap);        
        vidobj.fps=fpsVal;
        vidobj.quality=quality;
    end
    vidobj = addframe(vidobj,frame);
    if frameInd == totalFrames
        vidobj = close(vidobj);
    end
else
    switch codec
        case 0
            comp='Uncompressed AVI';
        case 1
            comp='Motion JPEG AVI';
        case 2
            comp='Archival';
            filename = filename(1:end-4); % removes the .avi from the extension so MATLAB can append a .mp2
            frame = frame2im(frame); % mp2 files need the input data structured not from 0 to 1
        case 3
            comp='Motion JPEG 2000';
            filename = filename(1:end-4); % removes the .avi from the extension so MATLAB can append a .mp2
            frame = frame2im(frame);
        otherwise
            error('Invalid codec/compression selection in requestVector input to movie generating function.');
    end
    if frameInd==1
        try
        vidobj = VideoWriter(filename,comp);
        catch err3
            warning('Incorrect codec setting for AVI file export. Using default Motion JPEG AVI profile...');
            vidobj = VideoWriter(filename);
        end
        vidobj.FrameRate=fpsVal;
        if codec == 1
            vidobj.Quality=quality;
        end
        open(vidobj);
        writeVideo(vidobj,frame);
    else
        writeVideo(vidobj,frame);
    end
    if frameInd == totalFrames
        close(vidobj);
    end
end

end

