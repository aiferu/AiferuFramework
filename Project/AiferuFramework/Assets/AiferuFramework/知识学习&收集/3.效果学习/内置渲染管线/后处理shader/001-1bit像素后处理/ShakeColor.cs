
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

/// <summary>
/// 实现反相shader后处理
/// </summary>
public class ShakeColor : PostEffectsBase
{
    #region Field
    public Shader briSatConShader;
    private Material briSatConMaterial;
    public Vector2 uv;
    public Texture _SplitTex1;
    public Texture _SplitTex2;
    public Texture _SplitTex3;
    public Texture _SplitTex4;
    public Texture _SplitTex5;

    [Range(0, 1)]
    public float _Split1To2 = 0.2f;
    [Range(0, 1)]
    public float _Split2To3 = 0.4f;
    [Range(0, 1)]
    public float _Split3To4 = 0.6f;
    [Range(0, 1)]
    public float _Split4To5 = 0.8f;
    #endregion

    #region Property
    /// <summary>
    /// 后处理shader生成的材质
    /// </summary>
    public Material material
    {
        get
        {
            briSatConMaterial = CheckShaderAndCreateMaterial(briSatConShader, briSatConMaterial);
            return briSatConMaterial;
        }
    }
    #endregion

    #region UnityOriginalEvent

    private void Update()
    {
        if (_Split1To2 >= _Split2To3)
        {
            _Split1To2 = _Split2To3 - 0.001f;
        }
        if (_Split2To3 >= _Split3To4)
        {
            _Split2To3 = _Split3To4 - 0.001f;
        }
        if (_Split3To4 >= _Split4To5)
        {
            _Split3To4 = _Split4To5 - 0.001f;

        }
    }

    //这个方法会在所有渲染完成后调用
    void OnRenderImage(RenderTexture src, RenderTexture dest)
    {
        if (material != null)
        {
            //使用着色器将源纹理复制到目标渲染纹理。

            material.SetTexture("_SplitTex1", _SplitTex1);
            material.SetTexture("_SplitTex2", _SplitTex2);
            material.SetTexture("_SplitTex3", _SplitTex3);
            material.SetTexture("_SplitTex4", _SplitTex4);
            material.SetTexture("_SplitTex5", _SplitTex5);
            material.SetTextureScale(Shader.PropertyToID("_SplitTex1"), uv);

            material.SetFloat("_Split1To2", _Split1To2);
            material.SetFloat("_Split2To3", _Split2To3);
            material.SetFloat("_Split3To4", _Split3To4);
            material.SetFloat("_Split4To5", _Split4To5);



            Graphics.Blit(src, dest, material);
        }
        else
        {
            Graphics.Blit(src, dest);
        }
    }
    #endregion

    #region Function

    #endregion

}
