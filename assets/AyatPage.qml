import bb.cascades 1.2
import com.canadainc.data 1.0

Page
{
    property int surahId
    property int ayatId
    property variant similarVerses
    property variant explanations
    
    onSimilarVersesChanged: {
        if (similarNarrations.length > 0) {
            titleControl.addOption(similarOption);
        } else { // unlinked everything
            hadithOption.selected = true;
        }
    }
    
    onExplanationsChanged: {
        titleControl.addOption(tafsirOption);
    }
    
    onAyatIdChanged: {
        if (ayatId > 0 && ayatId <= 286) {
            busy.delegateActive = true;
            helper.fetchHadith(root, arabicId);
        }
    }
    
    Container
    {
        
    }
}