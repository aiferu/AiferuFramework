//
//  PostEffectsBase.cs
//  AiferuFrameworkv0.1.1
//
//  Created by DefaultCompany on 2022/6/7.
//
//
using System.Collections;
using System.Collections.Generic;
using UnityEngine;


[ExecuteInEditMode]
[RequireComponent(typeof(Camera))]
/// <summary>
/// 后处理基类，需要放置在camera上
/// </summary>
public class PostEffectsBase : MonoBehaviour
{
    #region Field

    #endregion

    #region Property

    #endregion

    #region UnityOriginalEvent
    void Start()
    {
        CheckResources();
    }

    void Update()
    {

    }
    #endregion

    #region Function

    /// <summary>
    /// 检查东西当前平台是否支持图像处理
    /// </summary>
    /// <returns>可以返回ture，不可以返回false</returns>
    protected bool CheckSupport()
    {
        //检查当前平台是否支持图像后处理，现在基本所有的平台都支持，所以可以不判断
        if (SystemInfo.supportsImageEffects == false)
        {
            Debug.LogWarning("This platform does not support image effects.");
            return false;
        }

        return true;
    }

    /// <summary>
    /// 检查环境
    /// </summary>
    protected void CheckResources()
    {
        //当当前平台不支持图像后处理时，将该脚本关闭
        if (CheckSupport() == false)
        {
            enabled = false;
        }
    }


    /// <summary>
    /// 使用shader创建材质
    /// </summary>
    /// <param name="shader">使用的sheder</param>
    /// <param name="material">最终创建的材质</param>
    /// <returns></returns>
    protected Material CheckShaderAndCreateMaterial(Shader shader, Material material)
    {

        if (shader == null)
        {
            return null;
        }

        if (shader.isSupported && material && material.shader == shader)
            return material;

        if (!shader.isSupported)
        {
            return null;
        }
        else
        {
            material = new Material(shader);
            //设置meaterial为不可见，且在转换场景时不会被删除
            material.hideFlags = HideFlags.DontSave;
            if (material)
                return material;
            else
                return null;
        }
    }
    #endregion
}



