%  Visualize visual words (i.e. clusters)
%  To visually verify feature quantization computed above, we can show 
%  image patches corresponding to the same visual word. 
function visual_word_visualizer(num_words, desc_train)
figure;
    % num_words = size(VC,1) % loop over all visual word types
    fprintf('\nVisualize visual words (%d examples)\n', num_words);
    for i=1:num_words
      patches={};
      for j=1:length(desc_train) % loop over all images
        d=desc_train(j);
        ind=find(d.visword==i);
        if length(ind)
          % img=imread(strrep(d.imgfname,'_train',''));
          img=rgb2gray(imread(d.imgfname));
          
          x=d.c(ind); y=d.r(ind); r=d.rad(ind);
          bbox=[x-2*r y-2*r x+2*r y+2*r];
          for k=1:length(ind) % collect patches of a visual word i in image j      
            patches{end+1}=cropbbox(img,bbox(k,:));
          end
        end
      end
      % display all patches of the visual word i
      clf, showimage(combimage(patches,[],1.5))
      title(sprintf('%d examples of Visual Word #%d',length(patches),i))
      pause
    end