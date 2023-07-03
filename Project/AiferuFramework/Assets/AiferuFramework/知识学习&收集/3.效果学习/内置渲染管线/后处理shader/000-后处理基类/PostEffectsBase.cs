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
/// ������࣬��Ҫ������camera��
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
    /// ��鶫����ǰƽ̨�Ƿ�֧��ͼ����
    /// </summary>
    /// <returns>���Է���ture�������Է���false</returns>
    protected bool CheckSupport()
    {
        //��鵱ǰƽ̨�Ƿ�֧��ͼ��������ڻ������е�ƽ̨��֧�֣����Կ��Բ��ж�
        if (SystemInfo.supportsImageEffects == false)
        {
            Debug.LogWarning("This platform does not support image effects.");
            return false;
        }

        return true;
    }

    /// <summary>
    /// ��黷��
    /// </summary>
    protected void CheckResources()
    {
        //����ǰƽ̨��֧��ͼ�����ʱ�����ýű��ر�
        if (CheckSupport() == false)
        {
            enabled = false;
        }
    }


    /// <summary>
    /// ʹ��shader��������
    /// </summary>
    /// <param name="shader">ʹ�õ�sheder</param>
    /// <param name="material">���մ����Ĳ���</param>
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
            //����meaterialΪ���ɼ�������ת������ʱ���ᱻɾ��
            material.hideFlags = HideFlags.DontSave;
            if (material)
                return material;
            else
                return null;
        }
    }
    #endregion
}



