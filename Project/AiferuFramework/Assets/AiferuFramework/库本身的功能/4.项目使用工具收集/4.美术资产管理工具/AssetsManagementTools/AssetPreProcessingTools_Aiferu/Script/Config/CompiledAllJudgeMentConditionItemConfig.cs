#if UNITY_EDITOR
using System.Collections.Generic;
using UnityEngine;
namespace AiferuFramework.AssetsManagementTools
{
    public class CompiledAllJudgeMentConditionItemConfig : ScriptableObject
    {
        public List<TexturePreprocessorConfig> TexturteJudgeMent;
        public List<ModelPreprocessorConfig> MeshJudgeMent;
        public List<AudioPreprocessorConfig> AudioJudgeMent;

        public List<string> loopAnimationName;
    }
}
#endif
